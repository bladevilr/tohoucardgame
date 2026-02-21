extends Control
class_name VideoOverlay

signal video_finished

@onready var player: VideoStreamPlayer = $VideoStreamPlayer
@onready var image_rect: TextureRect = $ImageRect
@onready var skip_button: Button = $SkipButton
@onready var background: ColorRect = $Background

var _tween: Tween

func _ready():
	player.finished.connect(_on_video_finished)
	skip_button.pressed.connect(_on_skip_pressed)
	hide()

func play_video(stream: VideoStream):
	if not stream:
		push_warning("VideoOverlay: No stream provided.")
		_on_video_finished()
		return
		
	show()
	player.stream = stream
	player.play()
	# Optional: Fade in background?

func play_image(texture: Texture2D, duration: float = 3.0):
	if not texture:
		push_warning("VideoOverlay: No texture provided.")
		_on_video_finished()
		return
		
	show()
	player.hide()
	image_rect.show()
	image_rect.texture = texture
	image_rect.modulate.a = 0.0
	image_rect.scale = Vector2(1.0, 1.0)
	image_rect.pivot_offset = image_rect.size / 2.0
	
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(image_rect, "modulate:a", 1.0, 0.5)
	_tween.tween_property(image_rect, "scale", Vector2(1.05, 1.05), duration)
	_tween.chain().tween_callback(func():
		await get_tree().create_timer(0.5).timeout
		_on_video_finished()
	)

func _on_video_finished():
	if _tween: _tween.kill()
	player.stop()
	hide()
	video_finished.emit()

func _on_skip_pressed():
	_on_video_finished()

func is_playing() -> bool:
	return player.is_playing()
