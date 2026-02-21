extends CanvasLayer

var _overlay: ColorRect
var _is_busy = false

func _ready() -> void:
	layer = 90
	_overlay = ColorRect.new()
	_overlay.name = "FadeOverlay"
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

func change_scene(scene_path: String, fade_out_duration: float = 0.2, fade_in_duration: float = 0.2) -> void:
	if _is_busy:
		return
	call_deferred("_change_scene_async", scene_path, fade_out_duration, fade_in_duration)

func _change_scene_async(scene_path: String, fade_out_duration: float, fade_in_duration: float) -> void:
	_is_busy = true
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0, fade_out_duration)
	var err = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_warning("SceneTransition failed to load scene: %s" % scene_path)
	await get_tree().process_frame
	await _fade_to(0.0, fade_in_duration)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_busy = false

func _fade_to(alpha: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", alpha, maxf(0.01, duration)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
