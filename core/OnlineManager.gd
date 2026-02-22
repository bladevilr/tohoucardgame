extends Node

## OnlineManager — 在线排行榜客户端
## 负责与排行榜服务器通信，提交对局数据和获取排行榜。
## 所有请求静默失败，离线时游戏完全正常运行。

signal leaderboard_fetched(data: Dictionary)
signal match_submitted(response: Dictionary)
signal global_stats_fetched(data: Dictionary)
signal shadow_fetched(data: Dictionary)

const DEFAULT_SERVER_URL := "http://localhost:8081"
const TIMEOUT_SECONDS := 10.0

var server_url: String = DEFAULT_SERVER_URL
var client_id: String = ""
var _enabled: bool = true

func _ready() -> void:
	_load_client_id()
	_load_server_config()

# === client_id 管理 ===

func _load_client_id() -> void:
	client_id = SaveManager.get_client_id()
	if client_id.is_empty():
		client_id = _generate_uuid()
		SaveManager.set_client_id(client_id)

func _generate_uuid() -> String:
	var bytes := PackedByteArray()
	for i in range(16):
		bytes.append(randi() % 256)
	# UUID v4: version and variant bits
	bytes[6] = (bytes[6] & 0x0F) | 0x40
	bytes[8] = (bytes[8] & 0x3F) | 0x80
	var hex := bytes.hex_encode()
	return "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4),
		hex.substr(16, 4), hex.substr(20, 12)
	]

func _load_server_config() -> void:
	if FileAccess.file_exists("user://server_config.json"):
		var f := FileAccess.open("user://server_config.json", FileAccess.READ)
		if f:
			var parsed = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed is Dictionary:
				server_url = str(parsed.get("server_url", DEFAULT_SERVER_URL))
				_enabled = bool(parsed.get("enabled", true))

# === 公开 API ===

func submit_match(mode: String, result: String, chef_id: String,
		prestige: int, day: int,
		player_score: float = 0.0, opponent_score: float = 0.0) -> void:
	if not _enabled or client_id.is_empty():
		return
	var payload := {
		"client_id": client_id,
		"nickname": SaveManager.get_nickname(),
		"mode": mode,
		"result": result,
		"chef_id": chef_id,
		"prestige": prestige,
		"day": day,
		"player_score": player_score,
		"opponent_score": opponent_score,
	}
	_post("/api/submit_match", payload, func(response: Dictionary):
		match_submitted.emit(response)
	)

func fetch_leaderboard(limit: int = 50, offset: int = 0) -> void:
	if not _enabled:
		return
	var url := "/api/leaderboard?limit=%d&offset=%d&client_id=%s" % [limit, offset, client_id]
	_get(url, func(response: Dictionary):
		leaderboard_fetched.emit(response)
	)

func fetch_global_stats() -> void:
	if not _enabled:
		return
	_get("/api/stats", func(response: Dictionary):
		global_stats_fetched.emit(response)
	)

func register_nickname(nickname: String) -> void:
	if not _enabled or client_id.is_empty():
		return
	_post("/api/register", {"client_id": client_id, "nickname": nickname}, func(_r): pass)

func upload_shadow(snapshot: Dictionary) -> void:
	if not _enabled or client_id.is_empty():
		return
	var payload := {
		"client_id": client_id,
		"nickname": SaveManager.get_nickname(),
		"chef_id": str(snapshot.get("chef_id", "")),
		"day": int(snapshot.get("day", 0)),
		"snapshot": {
			"board": snapshot.get("board", []),
			"tools": snapshot.get("tools", []),
			"techniques": snapshot.get("techniques", []),
			"day": int(snapshot.get("day", 0)),
			"prestige": int(snapshot.get("prestige", 0)),
		},
	}
	_post("/api/upload_shadow", payload, func(_r): pass)

func fetch_random_shadow() -> void:
	if not _enabled or client_id.is_empty():
		return
	_get("/api/random_shadow?client_id=%s" % client_id, func(response: Dictionary):
		shadow_fetched.emit(response)
	)

# === HTTP 内部方法 ===

func _post(path: String, payload: Dictionary, callback: Callable) -> void:
	var http := HTTPRequest.new()
	http.timeout = TIMEOUT_SECONDS
	add_child(http)
	var body := JSON.stringify(payload)
	var headers := ["Content-Type: application/json"]
	http.request_completed.connect(func(req_result: int, code: int, _h: PackedStringArray, body_bytes: PackedByteArray):
		http.queue_free()
		if req_result != HTTPRequest.RESULT_SUCCESS or code < 200 or code >= 300:
			return
		var parsed = JSON.parse_string(body_bytes.get_string_from_utf8())
		if parsed is Dictionary:
			callback.call(parsed)
	)
	var err := http.request(server_url + path, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		http.queue_free()

func _get(path: String, callback: Callable) -> void:
	var http := HTTPRequest.new()
	http.timeout = TIMEOUT_SECONDS
	add_child(http)
	http.request_completed.connect(func(req_result: int, code: int, _h: PackedStringArray, body_bytes: PackedByteArray):
		http.queue_free()
		if req_result != HTTPRequest.RESULT_SUCCESS or code < 200 or code >= 300:
			return
		var parsed = JSON.parse_string(body_bytes.get_string_from_utf8())
		if parsed is Dictionary:
			callback.call(parsed)
	)
	var err := http.request(server_url + path)
	if err != OK:
		http.queue_free()
