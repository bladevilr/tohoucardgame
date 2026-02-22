#!/usr/bin/env python3
"""
TouhouBazaar Leaderboard API Server
Flask + SQLite backend for online leaderboard, player stats, and global analytics.
Usage: python leaderboard_server.py --host 0.0.0.0 --port 8081 --db leaderboard.db
"""

import argparse
import json
import sqlite3
import time
import threading
from datetime import datetime, timezone
from functools import wraps

from flask import Flask, request, jsonify, g

app = Flask(__name__)

# ---------------------------------------------------------------------------
#  Configuration
# ---------------------------------------------------------------------------
DB_PATH = "leaderboard.db"
STATS_TOKEN = ""  # Optional admin token for /api/stats
VALID_CHEFS = [
    "mystia", "sakuya", "youmu", "meiling", "marisa",
    "reimu", "alice", "patchouli", "reisen", "seija",
]
VALID_MODES = ["ranked", "casual"]
VALID_RESULTS = ["win", "loss"]
MAX_NICKNAME_LEN = 16

# ---------------------------------------------------------------------------
#  Rate limiting (in-memory)
# ---------------------------------------------------------------------------
_rate_lock = threading.Lock()
_rate_map: dict[str, float] = {}  # client_id -> last submit timestamp
RATE_LIMIT_SECONDS = 10.0


def _check_rate_limit(client_id: str) -> bool:
    now = time.time()
    with _rate_lock:
        last = _rate_map.get(client_id, 0.0)
        if now - last < RATE_LIMIT_SECONDS:
            return False
        _rate_map[client_id] = now
        # Prune old entries every 1000 inserts
        if len(_rate_map) > 5000:
            cutoff = now - 300
            to_del = [k for k, v in _rate_map.items() if v < cutoff]
            for k in to_del:
                del _rate_map[k]
        return True


# ---------------------------------------------------------------------------
#  Database helpers
# ---------------------------------------------------------------------------
def get_db() -> sqlite3.Connection:
    if "db" not in g:
        g.db = sqlite3.connect(DB_PATH)
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA journal_mode=WAL")
        g.db.execute("PRAGMA foreign_keys=ON")
    return g.db


@app.teardown_appcontext
def close_db(exception):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS players (
            client_id       TEXT PRIMARY KEY,
            nickname        TEXT NOT NULL DEFAULT '',
            ranked_wins     INTEGER NOT NULL DEFAULT 0,
            ranked_losses   INTEGER NOT NULL DEFAULT 0,
            casual_wins     INTEGER NOT NULL DEFAULT 0,
            casual_losses   INTEGER NOT NULL DEFAULT 0,
            rating          INTEGER NOT NULL DEFAULT 1000,
            best_prestige   INTEGER NOT NULL DEFAULT 0,
            best_day        INTEGER NOT NULL DEFAULT 0,
            last_chef_id    TEXT NOT NULL DEFAULT '',
            last_ip         TEXT NOT NULL DEFAULT '',
            first_seen      TEXT NOT NULL DEFAULT '',
            last_seen       TEXT NOT NULL DEFAULT '',
            created_at      TEXT NOT NULL DEFAULT (datetime('now'))
        );

        CREATE TABLE IF NOT EXISTS matches (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id       TEXT NOT NULL,
            mode            TEXT NOT NULL,
            result          TEXT NOT NULL,
            chef_id         TEXT NOT NULL,
            prestige        INTEGER NOT NULL DEFAULT 0,
            day             INTEGER NOT NULL DEFAULT 0,
            player_score    REAL NOT NULL DEFAULT 0,
            opponent_score  REAL NOT NULL DEFAULT 0,
            ip              TEXT NOT NULL DEFAULT '',
            submitted_at    TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (client_id) REFERENCES players(client_id)
        );

        CREATE TABLE IF NOT EXISTS known_ips (
            ip      TEXT PRIMARY KEY,
            first_seen TEXT NOT NULL DEFAULT (datetime('now'))
        );

        CREATE TABLE IF NOT EXISTS shadows (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id       TEXT NOT NULL,
            nickname        TEXT NOT NULL DEFAULT '',
            chef_id         TEXT NOT NULL DEFAULT '',
            snapshot        TEXT NOT NULL DEFAULT '{}',
            day             INTEGER NOT NULL DEFAULT 0,
            submitted_at    TEXT NOT NULL DEFAULT (datetime('now'))
        );

        CREATE INDEX IF NOT EXISTS idx_matches_client ON matches(client_id);
        CREATE INDEX IF NOT EXISTS idx_matches_time ON matches(submitted_at);
        CREATE INDEX IF NOT EXISTS idx_players_rating ON players(rating DESC);
        CREATE INDEX IF NOT EXISTS idx_shadows_client ON shadows(client_id);
    """)
    conn.commit()
    conn.close()


# ---------------------------------------------------------------------------
#  CORS
# ---------------------------------------------------------------------------
@app.after_request
def add_cors(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET,POST,OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return response


@app.route("/api/<path:path>", methods=["OPTIONS"])
def cors_preflight(path):
    return "", 204


# ---------------------------------------------------------------------------
#  Helper: get client IP
# ---------------------------------------------------------------------------
def _get_client_ip() -> str:
    forwarded = request.headers.get("X-Forwarded-For", "")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.remote_addr or ""


def _calc_rating(wins: int, losses: int) -> int:
    return max(800, 1000 + wins * 35 - losses * 20)


def _now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


# ---------------------------------------------------------------------------
#  API: POST /api/register
# ---------------------------------------------------------------------------
@app.route("/api/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}
    client_id = str(data.get("client_id", "")).strip()
    nickname = str(data.get("nickname", "")).strip()[:MAX_NICKNAME_LEN]

    if not client_id or len(client_id) < 8:
        return jsonify({"ok": False, "error": "invalid client_id"}), 400

    db = get_db()
    now = _now_iso()
    ip = _get_client_ip()

    db.execute("""
        INSERT OR IGNORE INTO players (client_id, nickname, first_seen, last_seen, last_ip)
        VALUES (?, ?, ?, ?, ?)
    """, (client_id, nickname, now, now, ip))

    db.execute("""
        UPDATE players SET nickname = ?, last_seen = ?, last_ip = ?
        WHERE client_id = ?
    """, (nickname, now, ip, client_id))

    db.execute("INSERT OR IGNORE INTO known_ips (ip) VALUES (?)", (ip,))
    db.commit()

    row = db.execute("SELECT * FROM players WHERE client_id = ?", (client_id,)).fetchone()
    return jsonify({"ok": True, "player": dict(row) if row else {}})


# ---------------------------------------------------------------------------
#  API: POST /api/submit_match
# ---------------------------------------------------------------------------
@app.route("/api/submit_match", methods=["POST"])
def submit_match():
    data = request.get_json(silent=True) or {}
    client_id = str(data.get("client_id", "")).strip()
    nickname = str(data.get("nickname", "")).strip()[:MAX_NICKNAME_LEN]
    mode = str(data.get("mode", "")).strip()
    result = str(data.get("result", "")).strip()
    chef_id = str(data.get("chef_id", "")).strip()
    prestige = int(data.get("prestige", 0))
    day = int(data.get("day", 0))
    player_score = float(data.get("player_score", 0))
    opponent_score = float(data.get("opponent_score", 0))

    # Validate
    if not client_id or len(client_id) < 8:
        return jsonify({"ok": False, "error": "invalid client_id"}), 400
    if mode not in VALID_MODES:
        return jsonify({"ok": False, "error": "invalid mode"}), 400
    if result not in VALID_RESULTS:
        return jsonify({"ok": False, "error": "invalid result"}), 400
    if chef_id not in VALID_CHEFS:
        return jsonify({"ok": False, "error": "invalid chef_id"}), 400

    # Rate limit
    if not _check_rate_limit(client_id):
        return jsonify({"ok": False, "error": "rate_limited"}), 429

    db = get_db()
    now = _now_iso()
    ip = _get_client_ip()

    # Ensure player exists
    db.execute("""
        INSERT OR IGNORE INTO players (client_id, nickname, first_seen, last_seen, last_ip)
        VALUES (?, ?, ?, ?, ?)
    """, (client_id, nickname or "", now, now, ip))

    # Insert match record
    db.execute("""
        INSERT INTO matches (client_id, mode, result, chef_id, prestige, day,
                             player_score, opponent_score, ip, submitted_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (client_id, mode, result, chef_id, prestige, day,
          player_score, opponent_score, ip, now))

    # Update player aggregates
    if mode == "ranked":
        if result == "win":
            db.execute("UPDATE players SET ranked_wins = ranked_wins + 1 WHERE client_id = ?", (client_id,))
        else:
            db.execute("UPDATE players SET ranked_losses = ranked_losses + 1 WHERE client_id = ?", (client_id,))
    else:
        if result == "win":
            db.execute("UPDATE players SET casual_wins = casual_wins + 1 WHERE client_id = ?", (client_id,))
        else:
            db.execute("UPDATE players SET casual_losses = casual_losses + 1 WHERE client_id = ?", (client_id,))

    # Recalculate rating
    row = db.execute("SELECT ranked_wins, ranked_losses FROM players WHERE client_id = ?", (client_id,)).fetchone()
    new_rating = _calc_rating(row["ranked_wins"], row["ranked_losses"]) if row else 1000

    # Update remaining fields
    update_fields = {
        "rating": new_rating,
        "last_chef_id": chef_id,
        "last_ip": ip,
        "last_seen": now,
    }
    if nickname:
        update_fields["nickname"] = nickname

    set_clause = ", ".join(f"{k} = ?" for k in update_fields)
    vals = list(update_fields.values()) + [client_id]
    db.execute(f"UPDATE players SET {set_clause} WHERE client_id = ?", vals)

    # Update best_prestige / best_day
    db.execute("""
        UPDATE players SET best_prestige = MAX(best_prestige, ?),
                           best_day = MAX(best_day, ?)
        WHERE client_id = ?
    """, (prestige, day, client_id))

    # Track IP
    db.execute("INSERT OR IGNORE INTO known_ips (ip) VALUES (?)", (ip,))
    db.commit()

    # Compute rank
    rank_row = db.execute("""
        SELECT COUNT(*) + 1 as rank FROM players
        WHERE rating > ? AND (ranked_wins + ranked_losses) > 0
    """, (new_rating,)).fetchone()
    rank = rank_row["rank"] if rank_row else 0

    return jsonify({"ok": True, "new_rating": new_rating, "rank": rank})


# ---------------------------------------------------------------------------
#  API: GET /api/leaderboard
# ---------------------------------------------------------------------------
@app.route("/api/leaderboard", methods=["GET"])
def leaderboard():
    limit = min(int(request.args.get("limit", 50)), 200)
    offset = max(int(request.args.get("offset", 0)), 0)
    client_id = request.args.get("client_id", "")

    db = get_db()

    rows = db.execute("""
        SELECT client_id, nickname, ranked_wins, ranked_losses,
               casual_wins, casual_losses, rating, best_prestige,
               best_day, last_chef_id, last_seen
        FROM players
        WHERE ranked_wins + ranked_losses > 0
        ORDER BY rating DESC
        LIMIT ? OFFSET ?
    """, (limit, offset)).fetchall()

    entries = []
    for i, row in enumerate(rows):
        r = dict(row)
        r["rank"] = offset + i + 1
        total = r["ranked_wins"] + r["ranked_losses"]
        r["winrate"] = round(r["ranked_wins"] / total, 3) if total > 0 else 0.0
        # Truncate client_id for privacy
        r["client_id"] = r["client_id"][:8] if r["client_id"] else ""
        entries.append(r)

    total_players = db.execute(
        "SELECT COUNT(*) as cnt FROM players WHERE ranked_wins + ranked_losses > 0"
    ).fetchone()["cnt"]

    your_rank = None
    if client_id:
        player_row = db.execute("SELECT rating FROM players WHERE client_id = ?", (client_id,)).fetchone()
        if player_row:
            rank_row = db.execute("""
                SELECT COUNT(*) + 1 as rank FROM players
                WHERE rating > ? AND (ranked_wins + ranked_losses) > 0
            """, (player_row["rating"],)).fetchone()
            your_rank = rank_row["rank"] if rank_row else None

    return jsonify({
        "leaderboard": entries,
        "total_players": total_players,
        "your_rank": your_rank,
    })


# ---------------------------------------------------------------------------
#  API: GET /api/player/<client_id>
# ---------------------------------------------------------------------------
@app.route("/api/player/<client_id>", methods=["GET"])
def player_stats(client_id: str):
    db = get_db()

    row = db.execute("SELECT * FROM players WHERE client_id = ?", (client_id,)).fetchone()
    if not row:
        return jsonify({"ok": False, "error": "player not found"}), 404

    player = dict(row)
    # Remove sensitive fields
    player.pop("last_ip", None)

    # Recent matches (last 20)
    match_rows = db.execute("""
        SELECT mode, result, chef_id, prestige, day, player_score, opponent_score, submitted_at
        FROM matches WHERE client_id = ?
        ORDER BY submitted_at DESC LIMIT 20
    """, (client_id,)).fetchall()
    recent = [dict(m) for m in match_rows]

    # Rank
    rank_row = db.execute("""
        SELECT COUNT(*) + 1 as rank FROM players
        WHERE rating > ? AND (ranked_wins + ranked_losses) > 0
    """, (row["rating"],)).fetchone()

    return jsonify({
        "ok": True,
        "player": player,
        "recent_matches": recent,
        "rank": rank_row["rank"] if rank_row else 0,
    })


# ---------------------------------------------------------------------------
#  API: GET /api/stats
# ---------------------------------------------------------------------------
@app.route("/api/stats", methods=["GET"])
def global_stats():
    # Optional token protection
    if STATS_TOKEN:
        token = request.args.get("token", "")
        if token != STATS_TOKEN:
            return jsonify({"ok": False, "error": "unauthorized"}), 403

    db = get_db()

    total_matches = db.execute("SELECT COUNT(*) as cnt FROM matches").fetchone()["cnt"]
    total_players = db.execute("SELECT COUNT(*) as cnt FROM players").fetchone()["cnt"]
    unique_ips = db.execute("SELECT COUNT(*) as cnt FROM known_ips").fetchone()["cnt"]

    active_24h = db.execute("""
        SELECT COUNT(DISTINCT client_id) as cnt FROM matches
        WHERE submitted_at > datetime('now', '-1 day')
    """).fetchone()["cnt"]

    matches_today = db.execute("""
        SELECT COUNT(*) as cnt FROM matches
        WHERE date(submitted_at) = date('now')
    """).fetchone()["cnt"]

    # Chef popularity
    chef_rows = db.execute("""
        SELECT chef_id,
               COUNT(*) as games,
               SUM(CASE WHEN result = 'win' THEN 1 ELSE 0 END) as wins
        FROM matches
        GROUP BY chef_id
        ORDER BY games DESC
    """).fetchall()

    chef_popularity = {}
    for cr in chef_rows:
        games = cr["games"]
        wins = cr["wins"]
        chef_popularity[cr["chef_id"]] = {
            "games": games,
            "wins": wins,
            "winrate": round(wins / games, 3) if games > 0 else 0.0,
        }

    # Average rating (of active players)
    avg_row = db.execute("""
        SELECT AVG(rating) as avg_rating FROM players
        WHERE ranked_wins + ranked_losses > 0
    """).fetchone()
    avg_rating = round(avg_row["avg_rating"]) if avg_row["avg_rating"] else 0

    return jsonify({
        "ok": True,
        "total_matches": total_matches,
        "total_players": total_players,
        "unique_ips": unique_ips,
        "active_players_24h": active_24h,
        "matches_today": matches_today,
        "chef_popularity": chef_popularity,
        "avg_rating": avg_rating,
    })


# ---------------------------------------------------------------------------
#  API: POST /api/upload_shadow
# ---------------------------------------------------------------------------
@app.route("/api/upload_shadow", methods=["POST"])
def upload_shadow():
    data = request.get_json(silent=True) or {}
    client_id = str(data.get("client_id", "")).strip()
    nickname = str(data.get("nickname", "")).strip()[:MAX_NICKNAME_LEN]
    chef_id = str(data.get("chef_id", "")).strip()
    snapshot = data.get("snapshot", {})
    day = int(data.get("day", 0))

    if not client_id or len(client_id) < 8:
        return jsonify({"ok": False, "error": "invalid client_id"}), 400

    # Serialize snapshot to JSON string for storage
    snapshot_str = json.dumps(snapshot, ensure_ascii=False) if isinstance(snapshot, dict) else str(snapshot)

    db = get_db()

    # Keep only latest shadow per player
    db.execute("DELETE FROM shadows WHERE client_id = ?", (client_id,))
    db.execute("""
        INSERT INTO shadows (client_id, nickname, chef_id, snapshot, day)
        VALUES (?, ?, ?, ?, ?)
    """, (client_id, nickname, chef_id, snapshot_str, day))
    db.commit()

    return jsonify({"ok": True})


# ---------------------------------------------------------------------------
#  API: GET /api/random_shadow
# ---------------------------------------------------------------------------
@app.route("/api/random_shadow", methods=["GET"])
def random_shadow():
    client_id = request.args.get("client_id", "")

    db = get_db()

    # Get a random shadow that is NOT from the requesting player
    if client_id:
        row = db.execute("""
            SELECT client_id, nickname, chef_id, snapshot, day
            FROM shadows
            WHERE client_id != ?
            ORDER BY RANDOM()
            LIMIT 1
        """, (client_id,)).fetchone()
    else:
        row = db.execute("""
            SELECT client_id, nickname, chef_id, snapshot, day
            FROM shadows
            ORDER BY RANDOM()
            LIMIT 1
        """).fetchone()

    if not row:
        return jsonify({"ok": False, "error": "no_shadows"})

    # Parse snapshot back from JSON string
    snapshot_str = row["snapshot"]
    try:
        snapshot = json.loads(snapshot_str)
    except (json.JSONDecodeError, TypeError):
        snapshot = {}

    return jsonify({
        "ok": True,
        "shadow": {
            "nickname": row["nickname"],
            "chef_id": row["chef_id"],
            "snapshot": snapshot,
            "day": row["day"],
        }
    })


# ---------------------------------------------------------------------------
#  Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="TouhouBazaar Leaderboard Server")
    parser.add_argument("--host", default="0.0.0.0", help="Bind host")
    parser.add_argument("--port", type=int, default=8081, help="Bind port")
    parser.add_argument("--db", default="leaderboard.db", help="SQLite database path")
    parser.add_argument("--stats-token", default="", help="Token for /api/stats access")
    parser.add_argument("--debug", action="store_true", help="Enable Flask debug mode")
    args = parser.parse_args()

    global DB_PATH, STATS_TOKEN
    DB_PATH = args.db
    STATS_TOKEN = args.stats_token

    init_db()
    print(f"Leaderboard server starting on {args.host}:{args.port}")
    print(f"Database: {args.db}")
    app.run(host=args.host, port=args.port, debug=args.debug)


if __name__ == "__main__":
    main()
