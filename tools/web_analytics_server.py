#!/usr/bin/env python3
"""
Static file server with lightweight analytics for Web exports.

Features:
- Serves files from build/web (or a custom directory)
- Injects a small tracker script into served HTML pages
- Records page-load events (IP, client_id, path, timestamp, user-agent)
- Exposes stats at /api/stats

Use this as a minimal self-hosted analytics layer when deploying the game.
"""

from __future__ import annotations

import argparse
import json
import threading
import time
from collections import Counter
from dataclasses import dataclass
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import parse_qs, unquote, urlparse


TRACKER_MARKER = "tbz-analytics-tracker"
TRACKER_SNIPPET = f"""
<script id="{TRACKER_MARKER}">
(() => {{
  const KEY = "tbz_client_id";
  let clientId = localStorage.getItem(KEY);
  if (!clientId) {{
    clientId = (typeof crypto !== "undefined" && crypto.randomUUID)
      ? crypto.randomUUID()
      : (Date.now().toString(36) + Math.random().toString(36).slice(2));
    localStorage.setItem(KEY, clientId);
  }}

  const payload = {{
    event: "page_load",
    client_id: clientId,
    path: location.pathname + location.search,
    referrer: document.referrer || ""
  }};

  const body = JSON.stringify(payload);
  if (navigator.sendBeacon) {{
    const blob = new Blob([body], {{ type: "application/json" }});
    navigator.sendBeacon("/api/track", blob);
  }} else {{
    fetch("/api/track", {{
      method: "POST",
      headers: {{ "Content-Type": "application/json" }},
      body,
      keepalive: true
    }}).catch(() => {{}});
  }}
}})();
</script>
""".strip()


def utc_iso(ts: float) -> str:
    return datetime.fromtimestamp(ts, tz=timezone.utc).isoformat().replace("+00:00", "Z")


@dataclass
class Event:
    ts: float
    ip: str
    client_id: str
    path: str
    referrer: str
    user_agent: str

    def to_json(self) -> dict[str, Any]:
        return {
            "ts": self.ts,
            "iso_time": utc_iso(self.ts),
            "ip": self.ip,
            "client_id": self.client_id,
            "path": self.path,
            "referrer": self.referrer,
            "user_agent": self.user_agent,
        }

    @staticmethod
    def from_json(raw: dict[str, Any]) -> "Event | None":
        try:
            ts = float(raw.get("ts", 0))
        except (TypeError, ValueError):
            return None
        if ts <= 0:
            return None
        return Event(
            ts=ts,
            ip=str(raw.get("ip", "")).strip(),
            client_id=str(raw.get("client_id", "")).strip(),
            path=str(raw.get("path", "")).strip(),
            referrer=str(raw.get("referrer", "")).strip(),
            user_agent=str(raw.get("user_agent", "")).strip(),
        )


class AnalyticsStore:
    def __init__(self, file_path: Path) -> None:
        self._file_path = file_path
        self._file_path.parent.mkdir(parents=True, exist_ok=True)
        self._lock = threading.Lock()
        self._events: list[Event] = []
        self._load_history()

    def _load_history(self) -> None:
        if not self._file_path.exists():
            return
        with self._file_path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    raw = json.loads(line)
                except json.JSONDecodeError:
                    continue
                event = Event.from_json(raw)
                if event is not None:
                    self._events.append(event)

    def add(self, event: Event) -> None:
        row = event.to_json()
        with self._lock:
            self._events.append(event)
            with self._file_path.open("a", encoding="utf-8") as f:
                f.write(json.dumps(row, ensure_ascii=False, separators=(",", ":")) + "\n")

    def get_stats(self) -> dict[str, Any]:
        now = time.time()
        day_ago = now - 86400
        week_ago = now - 86400 * 7
        today_utc = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0).timestamp()

        with self._lock:
            events = list(self._events)

        if not events:
            return {
                "total_events": 0,
                "unique_ips": 0,
                "unique_clients": 0,
                "unique_ips_24h": 0,
                "unique_ips_7d": 0,
                "unique_ips_today": 0,
                "first_seen": None,
                "last_seen": None,
                "top_paths": [],
                "by_day": [],
            }

        unique_ips = {e.ip for e in events if e.ip}
        unique_clients = {e.client_id for e in events if e.client_id}
        unique_ips_24h = {e.ip for e in events if e.ip and e.ts >= day_ago}
        unique_ips_7d = {e.ip for e in events if e.ip and e.ts >= week_ago}
        unique_ips_today = {e.ip for e in events if e.ip and e.ts >= today_utc}

        path_counter = Counter(e.path or "/" for e in events)

        day_buckets: dict[str, dict[str, Any]] = {}
        for event in events:
            day = datetime.fromtimestamp(event.ts, tz=timezone.utc).strftime("%Y-%m-%d")
            bucket = day_buckets.setdefault(day, {"events": 0, "ips": set(), "clients": set()})
            bucket["events"] += 1
            if event.ip:
                bucket["ips"].add(event.ip)
            if event.client_id:
                bucket["clients"].add(event.client_id)

        by_day = []
        for day in sorted(day_buckets.keys()):
            bucket = day_buckets[day]
            by_day.append(
                {
                    "day": day,
                    "events": bucket["events"],
                    "unique_ips": len(bucket["ips"]),
                    "unique_clients": len(bucket["clients"]),
                }
            )

        min_ts = min(e.ts for e in events)
        max_ts = max(e.ts for e in events)

        return {
            "total_events": len(events),
            "unique_ips": len(unique_ips),
            "unique_clients": len(unique_clients),
            "unique_ips_24h": len(unique_ips_24h),
            "unique_ips_7d": len(unique_ips_7d),
            "unique_ips_today": len(unique_ips_today),
            "first_seen": utc_iso(min_ts),
            "last_seen": utc_iso(max_ts),
            "top_paths": [{"path": p, "count": c} for p, c in path_counter.most_common(20)],
            "by_day": by_day,
        }


def create_handler(
    *,
    root_dir: Path,
    store: AnalyticsStore,
    stats_token: str,
    trust_x_forwarded_for: bool,
):
    class AnalyticsHandler(SimpleHTTPRequestHandler):
        server_version = "TouhouBazaarAnalytics/1.0"

        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=str(root_dir), **kwargs)

        def do_OPTIONS(self) -> None:  # noqa: N802 (HTTP verb naming)
            if self.path.startswith("/api/"):
                self.send_response(HTTPStatus.NO_CONTENT)
                self._set_cors_headers()
                self.end_headers()
                return
            self.send_error(HTTPStatus.NOT_FOUND)

        def do_GET(self) -> None:  # noqa: N802 (HTTP verb naming)
            parsed = urlparse(self.path)
            if parsed.path == "/api/stats":
                self._handle_stats(parsed.query)
                return
            if parsed.path == "/api/track":
                self._handle_track_get(parsed.query)
                return

            if self._looks_like_html(parsed.path):
                if self._serve_html_with_tracker(parsed.path):
                    return

            super().do_GET()

        def do_POST(self) -> None:  # noqa: N802 (HTTP verb naming)
            parsed = urlparse(self.path)
            if parsed.path != "/api/track":
                self.send_error(HTTPStatus.NOT_FOUND, "Unknown API endpoint")
                return

            max_body = 64 * 1024
            content_len = int(self.headers.get("Content-Length", "0") or 0)
            content_len = min(content_len, max_body)
            body = self.rfile.read(content_len) if content_len > 0 else b"{}"
            try:
                payload = json.loads(body.decode("utf-8"))
                if not isinstance(payload, dict):
                    payload = {}
            except json.JSONDecodeError:
                payload = {}

            self._record_event(payload)
            self._send_json({"ok": True})

        def _looks_like_html(self, path: str) -> bool:
            if path in ("", "/"):
                return True
            clean = unquote(path)
            if clean.endswith("/"):
                return True
            return clean.lower().endswith(".html")

        def _serve_html_with_tracker(self, request_path: str) -> bool:
            fs_path = Path(self.translate_path(request_path))
            if fs_path.is_dir():
                fs_path = fs_path / "index.html"
            if not fs_path.exists() or fs_path.suffix.lower() != ".html":
                return False

            try:
                original = fs_path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                original = fs_path.read_text(encoding="utf-8", errors="ignore")

            html = self._inject_tracker(original)
            body = html.encode("utf-8")

            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return True

        def _inject_tracker(self, html: str) -> str:
            if TRACKER_MARKER in html:
                return html
            lower = html.lower()
            head_idx = lower.rfind("</head>")
            if head_idx >= 0:
                return html[:head_idx] + "\n" + TRACKER_SNIPPET + "\n" + html[head_idx:]
            body_idx = lower.rfind("</body>")
            if body_idx >= 0:
                return html[:body_idx] + "\n" + TRACKER_SNIPPET + "\n" + html[body_idx:]
            return html + "\n" + TRACKER_SNIPPET + "\n"

        def _handle_track_get(self, query_string: str) -> None:
            query = parse_qs(query_string, keep_blank_values=True)
            payload = {k: v[0] for k, v in query.items() if v}
            self._record_event(payload)
            self.send_response(HTTPStatus.NO_CONTENT)
            self._set_cors_headers()
            self.send_header("Cache-Control", "no-store")
            self.end_headers()

        def _record_event(self, payload: dict[str, Any]) -> None:
            event = Event(
                ts=time.time(),
                ip=self._get_client_ip(),
                client_id=str(payload.get("client_id", "")).strip()[:128],
                path=str(payload.get("path", self.path)).strip()[:512],
                referrer=str(payload.get("referrer", "")).strip()[:1024],
                user_agent=self.headers.get("User-Agent", "")[:512],
            )
            store.add(event)

        def _handle_stats(self, query_string: str) -> None:
            if stats_token:
                query = parse_qs(query_string, keep_blank_values=True)
                token = ""
                if "token" in query and query["token"]:
                    token = query["token"][0]
                elif "X-Stats-Token" in self.headers:
                    token = self.headers["X-Stats-Token"]
                if token != stats_token:
                    self._send_json({"ok": False, "error": "forbidden"}, status=HTTPStatus.FORBIDDEN)
                    return

            stats = store.get_stats()
            self._send_json(stats)

        def _send_json(self, payload: dict[str, Any], *, status: HTTPStatus = HTTPStatus.OK) -> None:
            body = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
            self.send_response(status)
            self._set_cors_headers()
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(body)

        def _set_cors_headers(self) -> None:
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET,POST,OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type,X-Stats-Token")

        def _get_client_ip(self) -> str:
            direct_ip = self.client_address[0] if self.client_address else ""
            if not trust_x_forwarded_for:
                return direct_ip

            xff = self.headers.get("X-Forwarded-For", "")
            if not xff:
                return direct_ip
            forwarded = xff.split(",")[0].strip()
            return forwarded or direct_ip

    return AnalyticsHandler


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Serve static files with unique-IP analytics.")
    parser.add_argument("--root", default="build/web", help="Static file root directory.")
    parser.add_argument("--host", default="0.0.0.0", help="Bind host. Default: 0.0.0.0")
    parser.add_argument("--port", default=8080, type=int, help="Bind port. Default: 8080")
    parser.add_argument(
        "--data-file",
        default="debug/web_analytics/events.jsonl",
        help="Path to JSONL analytics data file.",
    )
    parser.add_argument(
        "--stats-token",
        default="",
        help="Optional token required for /api/stats (query ?token=... or X-Stats-Token header).",
    )
    parser.add_argument(
        "--trust-x-forwarded-for",
        action="store_true",
        help="Trust X-Forwarded-For for real client IP (enable behind reverse proxy).",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root_dir = Path(args.root).resolve()
    data_file = Path(args.data_file).resolve()

    if not root_dir.exists() or not root_dir.is_dir():
        print(f"[error] root directory not found: {root_dir}")
        return 1

    store = AnalyticsStore(data_file)
    handler_cls = create_handler(
        root_dir=root_dir,
        store=store,
        stats_token=args.stats_token,
        trust_x_forwarded_for=args.trust_x_forwarded_for,
    )

    server = ThreadingHTTPServer((args.host, args.port), handler_cls)
    print(f"[info] serving: {root_dir}")
    print(f"[info] listen:  http://{args.host}:{args.port}/")
    print(f"[info] stats:   http://{args.host}:{args.port}/api/stats")
    if args.stats_token:
        print("[info] stats endpoint is protected by token")
    print(f"[info] data:    {data_file}")
    print("[info] press Ctrl+C to stop")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[info] stopping...")
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
