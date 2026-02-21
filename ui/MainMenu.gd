extends Control

const TutorialOverlayScene = preload("res://ui/TutorialOverlay.tscn")
const TextureGeneratorTool = preload("res://tools/TextureGenerator.gd")

@onready var background: TextureRect = $Background
@onready var deco_frame: PanelContainer = $DecoFrame
@onready var title_label: Label = $DecoFrame/VBox/TitleLabel
@onready var subtitle_label: Label = $DecoFrame/VBox/SubtitleLabel
@onready var desc_label: Label = $DecoFrame/VBox/DescLabel
@onready var start_button: Button = $DecoFrame/VBox/StartButton
@onready var tutorial_button: Button = $DecoFrame/VBox/TutorialButton
@onready var quit_button: Button = $DecoFrame/VBox/QuitButton
var leaderboard_button: Button = null

func _ready():
	TextureGeneratorTool.generate_if_needed()
	_apply_background_shader()
	_apply_frame_style()
	_apply_button_styles()
	start_button.pressed.connect(_on_start)
	tutorial_button.pressed.connect(_on_tutorial)
	quit_button.pressed.connect(_on_quit)
	_add_leaderboard_button()
	_show_nickname_tag()
	_apply_responsive_layout()
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_animate_intro()

func _apply_frame_style() -> void:
	pass

func _apply_button_styles() -> void:
	pass

func _style_primary_button(btn: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.24, 0.18, 0.08, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.96, 0.82, 0.28)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color(0.30, 0.24, 0.12, 0.95)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))
	btn.add_theme_font_size_override("font_size", 20)

func _style_secondary_button(btn: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.227, 0.176, 0.314, 0.85)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.545, 0.396, 0.306)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate()
	hover.bg_color = Color(0.29, 0.24, 0.38, 0.9)
	hover.border_color = Color(0.788, 0.643, 0.290)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_color_override("font_color", Color(0.941, 0.902, 0.827))
	btn.add_theme_font_size_override("font_size", 16)

func _apply_responsive_layout() -> void:
	var vp: Vector2 = get_viewport_rect().size
	if vp.x <= 0.0 or vp.y <= 0.0:
		return

	var frame_w := clampf(vp.x - 48.0, 300.0, 480.0)
	var frame_h := clampf(vp.y - 48.0, 340.0, 440.0)
	deco_frame.offset_left = -frame_w * 0.5
	deco_frame.offset_right = frame_w * 0.5
	deco_frame.offset_top = -frame_h * 0.5
	deco_frame.offset_bottom = frame_h * 0.5

	var ui_scale := clampf(minf(vp.x / 1280.0, vp.y / 720.0), 0.72, 1.0)
	title_label.add_theme_font_size_override("font_size", int(round(48.0 * ui_scale)))
	subtitle_label.add_theme_font_size_override("font_size", int(round(18.0 * ui_scale)))
	desc_label.add_theme_font_size_override("font_size", int(round(16.0 * ui_scale)))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var primary_w := clampf(frame_w * 0.56, 170.0, 220.0)
	var primary_h := maxf(44.0, 50.0 * ui_scale)
	start_button.custom_minimum_size = Vector2(primary_w, primary_h)

	var secondary_h := maxf(40.0, 42.0 * ui_scale)
	tutorial_button.custom_minimum_size = Vector2(primary_w, secondary_h)
	quit_button.custom_minimum_size = Vector2(primary_w, secondary_h)
	if leaderboard_button:
		leaderboard_button.custom_minimum_size = Vector2(primary_w, secondary_h)

func _animate_intro() -> void:
	deco_frame.modulate.a = 0.0
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	desc_label.modulate.a = 0.0
	start_button.modulate.a = 0.0
	tutorial_button.modulate.a = 0.0
	if leaderboard_button:
		leaderboard_button.modulate.a = 0.0
	quit_button.modulate.a = 0.0

	var anims = get_node_or_null("/root/UIAnimations")
	if anims and anims.has_method("fade_in"):
		anims.call("fade_in", deco_frame, 0.4, 0.0)
		anims.call("fade_in", title_label, 0.5, 0.1)
		anims.call("fade_in", subtitle_label, 0.4, 0.25)
		anims.call("fade_in", desc_label, 0.4, 0.35)
		anims.call("slide_in_from_bottom", start_button, 24.0, 0.3, 0.4)
		anims.call("slide_in_from_bottom", tutorial_button, 24.0, 0.3, 0.5)
		if leaderboard_button:
			anims.call("slide_in_from_bottom", leaderboard_button, 24.0, 0.3, 0.6)
		anims.call("slide_in_from_bottom", quit_button, 24.0, 0.3, 0.7)
		anims.call("pulse", title_label, 1.03, 1.6)
	else:
		deco_frame.modulate.a = 1.0
		title_label.modulate.a = 1.0
		subtitle_label.modulate.a = 1.0
		desc_label.modulate.a = 1.0
		start_button.modulate.a = 1.0
		tutorial_button.modulate.a = 1.0
		if leaderboard_button:
			leaderboard_button.modulate.a = 1.0
		quit_button.modulate.a = 1.0

func _apply_background_shader() -> void:
	if background == null:
		return
	# Keep the title background texture visible; the shared gradient shader
	# is fully opaque and would otherwise hide the image.
	if background.texture != null:
		background.material = null
		background.modulate = Color(1, 1, 1, 1)
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		return
	var shader = load("res://ui/shaders/background_gradient.gdshader")
	if shader:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		background.material = mat

func _on_start():
	var transition = get_node_or_null("/root/SceneTransition")
	if transition and transition.has_method("change_scene"):
		transition.call("change_scene", "res://ui/GameModeSelect.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/GameModeSelect.tscn")

func _add_leaderboard_button() -> void:
	var vbox := get_node_or_null("DecoFrame/VBox")
	if vbox == null:
		return
	var lb_btn := Button.new()
	lb_btn.text = "排行榜 / 战绩"
	lb_btn.pressed.connect(func():
		get_tree().change_scene_to_file("res://ui/Leaderboard.tscn")
	)
	# Insert before QuitButton — no style overrides so global theme applies
	var quit_idx: int = quit_button.get_index()
	vbox.add_child(lb_btn)
	vbox.move_child(lb_btn, quit_idx)
	leaderboard_button = lb_btn

func _show_nickname_tag() -> void:
	var nick: String = SaveManager.get_nickname()
	if nick == "":
		return
	var lbl := Label.new()
	lbl.text = nick
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.85, 0.78, 1.0, 0.9))
	lbl.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	lbl.position = Vector2(-200, 18)
	add_child(lbl)

func _on_tutorial():
	var overlay = TutorialOverlayScene.instantiate()
	add_child(overlay)
	overlay.start_tutorial()
	overlay.tutorial_completed.connect(func():
		overlay.queue_free()
	)

func _on_quit():
	get_tree().quit()
