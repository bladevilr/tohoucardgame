extends CanvasLayer

var _overlay: ColorRect
var _shake_tween: Tween

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.name = "EnvironmentOverlay"
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0, 0, 0, 0)
	var shader = load("res://ui/shaders/environment_overlay.gdshader")
	if shader:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		_overlay.material = mat
	add_child(_overlay)

func shake(strength: float = 2.0, duration: float = 0.1) -> void:
	var scene: Node = get_tree().current_scene
	if scene == null or not (scene is CanvasItem):
		return
	if _shake_tween:
		_shake_tween.kill()
	var item: CanvasItem = scene as CanvasItem
	var original: Vector2 = item.position
	_shake_tween = create_tween()
	for i in range(6):
		var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		_shake_tween.tween_property(item, "position", original + offset, duration / 7.0)
	_shake_tween.tween_property(item, "position", original, duration / 7.0)

func set_environment(greasy_stacks: int, fatigue_stacks: int, fade_duration: float = 0.25) -> void:
	var target_alpha = 0.0
	if greasy_stacks > 0 or fatigue_stacks > 0:
		target_alpha = clampf(0.22 + greasy_stacks * 0.06 + fatigue_stacks * 0.08, 0.0, 0.65)
	var mat = _overlay.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("greasy_intensity", clampf(float(greasy_stacks) / 5.0, 0.0, 1.0))
		mat.set_shader_parameter("fatigue_intensity", clampf(float(fatigue_stacks) / 4.0, 0.0, 1.0))
	create_tween().tween_property(_overlay, "color:a", target_alpha, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func clear_environment(fade_duration: float = 0.3) -> void:
	set_environment(0, 0, fade_duration)

func pulse_pressure(intensity: float = 0.22, duration: float = 0.4) -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", clampf(_overlay.color.a + intensity, 0.0, 0.7), duration * 0.5)
	tween.tween_property(_overlay, "color:a", 0.0, duration * 0.5)
