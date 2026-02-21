extends Node

var _bgm_player: AudioStreamPlayer
var _current_bgm_path: String = ""

const BGM_PARADISE = "res://assets/audio/bgm/paradise_deep_mountain.mp3"

func _ready() -> void:
	# Create persistent BGM player
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master" # Or "Music" if bus exists
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)
	
	# Start playing default BGM
	play_bgm(BGM_PARADISE)

	if SignalBus == null:
		return
	SignalBus.item_purchased.connect(func(_p, _i): _play_sfx("item_purchased"))
	SignalBus.item_placed.connect(func(_p, _idx, _i): _play_sfx("item_placed"))
	SignalBus.showdown_item_served.connect(func(_p, _idx, _r): _play_sfx("item_served"))
	SignalBus.keyword_gained.connect(func(_p, _idx, _id, _s): _play_sfx("keyword_gained"))
	SignalBus.phase_changed.connect(func(_phase): _play_sfx("phase_changed"))

func play_bgm(path: String, fade_duration: float = 1.0) -> void:
	if _current_bgm_path == path and _bgm_player.playing:
		return
		
	var stream = load(path)
	if stream:
		if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
			stream.loop = true # Set loop if supported
			
		# Simple crossfade logic could go here, for now just play
		_bgm_player.stream = stream
		_bgm_player.play()
		_current_bgm_path = path
		print("Playing BGM: ", path)
	else:
		push_error("Failed to load BGM: " + path)

func _play_sfx(event_name: String) -> void:
	# Reserved for future SFX implementation
	# if OS.is_debug_build():
	# 	print("SFX Event: ", event_name)
	pass
