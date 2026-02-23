extends Node

## 本地存档管理器 — 保存玩家昵称、战绩、统计数据

const SAVE_PATH := "user://player_profile.json"

var _data: Dictionary = {}

func _ready() -> void:
	load_data()

func load_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			var text := f.get_as_text()
			f.close()
			var parsed = JSON.parse_string(text)
			if parsed is Dictionary:
				_data = parsed
				return
	_reset_data()

func _reset_data() -> void:
	_data = {
		"nickname": "",
		"ranked_wins": 0, "ranked_losses": 0,
		"casual_wins": 0, "casual_losses": 0,
		"best_prestige": 0, "best_day": 0,
		"chef_stats": {},
		"history": [],
		"shadow_pool": [],
		"client_id": "",
		"tutorial_done": false
	}

func save_data() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_data, "\t"))
		f.close()

func has_nickname() -> bool:
	return get_nickname() != ""

func get_nickname() -> String:
	return str(_data.get("nickname", ""))

func set_nickname(n: String) -> void:
	_data["nickname"] = n.strip_edges().left(16)
	save_data()

func get_player_rating() -> int:
	var w := int(_data.get("ranked_wins", 0))
	var l := int(_data.get("ranked_losses", 0))
	return maxi(800, 1000 + w * 35 - l * 20)

func get_stats() -> Dictionary:
	return _data.duplicate(true)

func get_chef_stat(chef_id: String) -> Dictionary:
	var cs: Dictionary = _data.get("chef_stats", {})
	return cs.get(chef_id, {"games": 0, "wins": 0}).duplicate()

func get_total_games() -> int:
	return int(_data.get("ranked_wins", 0)) + int(_data.get("ranked_losses", 0)) \
		+ int(_data.get("casual_wins", 0)) + int(_data.get("casual_losses", 0))

func get_ranked_winrate() -> float:
	var w := int(_data.get("ranked_wins", 0))
	var l := int(_data.get("ranked_losses", 0))
	var total := w + l
	return float(w) / float(total) if total > 0 else 0.0

func record_match(mode: String, result: String, chef_id: String, prestige: int, day: int) -> void:
	var key := mode + ("_wins" if result == "win" else "_losses")
	_data[key] = int(_data.get(key, 0)) + 1
	if prestige > int(_data.get("best_prestige", 0)):
		_data["best_prestige"] = prestige
	if day > int(_data.get("best_day", 0)):
		_data["best_day"] = day
	var cs: Dictionary = _data.get("chef_stats", {})
	if not cs.has(chef_id):
		cs[chef_id] = {"games": 0, "wins": 0}
	cs[chef_id]["games"] = int(cs[chef_id]["games"]) + 1
	if result == "win":
		cs[chef_id]["wins"] = int(cs[chef_id]["wins"]) + 1
	_data["chef_stats"] = cs
	var history: Array = _data.get("history", [])
	history.insert(0, {"mode": mode, "result": result, "chef_id": chef_id, "prestige": prestige, "day": day})
	if history.size() > 20:
		history.resize(20)
	_data["history"] = history
	save_data()

const MAX_SHADOWS := 10

func save_shadow(snapshot: Dictionary) -> void:
	var pool: Array = _data.get("shadow_pool", [])
	pool.append(snapshot)
	if pool.size() > MAX_SHADOWS:
		pool = pool.slice(pool.size() - MAX_SHADOWS)
	_data["shadow_pool"] = pool
	save_data()

func get_shadow_opponents() -> Array:
	return _data.get("shadow_pool", [])

func get_random_shadow() -> Dictionary:
	var pool: Array = _data.get("shadow_pool", [])
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()]

func set_client_id(id: String) -> void:
	_data["client_id"] = id
	save_data()

func get_client_id() -> String:
	return str(_data.get("client_id", ""))

func is_tutorial_done() -> bool:
	return bool(_data.get("tutorial_done", false))

func set_tutorial_done() -> void:
	_data["tutorial_done"] = true
	save_data()
