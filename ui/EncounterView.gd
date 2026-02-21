extends Control

const FloatingTextScript = preload("res://ui/effects/FloatingText.gd")

var _encounter: Dictionary = {}
var _is_pve: bool = false
var _result_shown: bool = false
var _choice_buttons: Array = []

@onready var background: ColorRect = $Background
@onready var title_label: Label = $CenterPanel/VBox/TitleRow/TitleLabel
@onready var flavor_label: Label = $CenterPanel/VBox/FlavorLabel
@onready var desc_label: Label = $CenterPanel/VBox/DescLabel
@onready var choices_container: VBoxContainer = $CenterPanel/VBox/ChoicesContainer
@onready var result_label: Label = $CenterPanel/VBox/ResultLabel
@onready var continue_button: Button = $CenterPanel/VBox/ContinueButton
@onready var panel: PanelContainer = $CenterPanel

func _ready():
	_apply_background_shader()
	_style_panel()
	_load_encounter()
	_display_encounter()
	result_label.visible = false
	continue_button.visible = false
	continue_button.pressed.connect(_on_continue)
	_animate_intro()

func _apply_background_shader() -> void:
	var shader = load("res://ui/shaders/background_gradient.gdshader")
	if shader != null:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		background.material = mat

func _style_panel() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.10, 0.18, 0.94)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.36, 0.34, 0.5)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 8
	panel.add_theme_stylebox_override("panel", style)

func _load_encounter() -> void:
	var match_state = GameManager.get_match_state()
	if match_state == null:
		_encounter = {"id": "empty", "name": "无事发生", "choices": [], "type": "event"}
		return
	var phase = match_state.current_phase
	if phase == GameConfig.Phase.PVE_BATTLE:
		_is_pve = true
		_encounter = match_state.current_encounter
		if _encounter.is_empty():
			_encounter = EncounterManager.generate_pve_opponent(match_state.current_day)
	else:
		_is_pve = false
		_encounter = match_state.current_encounter
		if _encounter.is_empty():
			_encounter = EncounterManager.generate_encounter_for_action(
				"morning_event", match_state.current_day, 1)

func _display_encounter() -> void:
	title_label.text = _encounter.get("name", "事件")
	flavor_label.text = _encounter.get("flavor_text", _encounter.get("flavor", ""))
	desc_label.text = _encounter.get("description", _encounter.get("desc", ""))
	if _is_pve:
		_display_pve()
	else:
		_display_event_choices()

func _display_pve() -> void:
	var difficulty = _encounter.get("difficulty", 1)
	var diff_text = "简单" if difficulty <= 1 else ("普通" if difficulty == 2 else "困难")
	var diff_color = Color(0.3, 0.9, 0.4) if difficulty <= 1 else (Color(0.95, 0.85, 0.2) if difficulty == 2 else Color(0.95, 0.3, 0.3))
	var reward_gold = _encounter.get("reward_gold", 3)
	flavor_label.text = _encounter.get("flavor", "")
	desc_label.text = "%s\n\n难度: %s  |  奖励: %d金币" % [
		_encounter.get("desc", ""), diff_text, reward_gold]
	var fight_btn = _create_choice_button("迎战", diff_color.lightened(0.3))
	fight_btn.pressed.connect(_on_pve_fight)
	choices_container.add_child(fight_btn)
	_choice_buttons.append(fight_btn)
	var skip_btn = _create_choice_button("跳过试营业", Color(0.7, 0.7, 0.7))
	skip_btn.pressed.connect(_on_pve_skip)
	choices_container.add_child(skip_btn)
	_choice_buttons.append(skip_btn)

func _display_event_choices() -> void:
	var choices = _encounter.get("choices", [])
	if choices.is_empty():
		var skip_btn = _create_choice_button("继续", Color(0.7, 0.7, 0.7))
		skip_btn.pressed.connect(_on_continue)
		choices_container.add_child(skip_btn)
		_choice_buttons.append(skip_btn)
		return
	for i in range(choices.size()):
		var choice = choices[i]
		var label_text = choice.get("label", "选项%d" % (i + 1))
		var text = choice.get("text", "")
		var display = "[%s] %s" % [label_text, text] if text != "" else label_text
		var colors = [Color(0.82, 1.0, 0.85), Color(0.85, 0.85, 1.0), Color(1.0, 0.85, 0.75)]
		var btn = _create_choice_button(display, colors[i % colors.size()])
		btn.pressed.connect(_on_choice.bind(i))
		choices_container.add_child(btn)
		_choice_buttons.append(btn)

func _create_choice_button(text: String, font_color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 44)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", font_color)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.13, 0.22, 0.9)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.4, 0.38, 0.55, 0.6)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	style.content_margin_left = 16
	style.content_margin_right = 16
	btn.add_theme_stylebox_override("normal", style)
	var hover = style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.22, 0.20, 0.32, 0.95)
	hover.border_color = Color(0.6, 0.55, 0.75, 0.8)
	btn.add_theme_stylebox_override("hover", hover)
	return btn

func _on_choice(choice_idx: int) -> void:
	var player = GameManager.get_player(0)
	if player == null:
		_show_result("无法执行")
		return
	var result = EncounterManager.resolve_encounter(player, _encounter, choice_idx)
	for reward in result.get("rewards", []):
		var placed = BoardManager.auto_place_item(player, reward)
		if placed < 0:
			player.add_to_backpack(reward)
	var text = result.get("text", "已完成")
	if result.has("gold_gained") and int(result.gold_gained) > 0:
		text += "\n+%d 金币" % int(result.gold_gained)
	if result.has("gold_lost") and int(result.gold_lost) > 0:
		text += "\n-%d 金币" % int(result.gold_lost)
	if result.has("prestige_lost") and int(result.prestige_lost) > 0:
		text += "\n声望 -%d" % int(result.prestige_lost)
	if not result.get("rewards", []).is_empty():
		text += "\n获得奖励物品"
	_show_result(text)

func _on_pve_fight() -> void:
	# Advance to PREP → SHOWDOWN flow (same as PvP)
	GameManager.advance_phase()
	_transition_to("res://ui/GameBoard.tscn")

func _on_pve_skip() -> void:
	# Skip PvE entirely and return to shop
	GameManager.change_phase(GameConfig.Phase.SHOP)
	_transition_to("res://ui/GameBoard.tscn")

func _show_result(text: String) -> void:
	_result_shown = true
	result_label.text = text
	result_label.visible = true
	continue_button.visible = true
	for btn in _choice_buttons:
		btn.disabled = true
		btn.modulate = Color(0.6, 0.6, 0.6, 0.7)
	var anims = get_node_or_null("/root/UIAnimations")
	if anims and anims.has_method("fade_in"):
		anims.call("fade_in", result_label, 0.3, 0.0)

func _on_continue() -> void:
	GameManager.advance_phase()
	_transition_to("res://ui/GameBoard.tscn")

func _animate_intro() -> void:
	var anims = get_node_or_null("/root/UIAnimations")
	if anims and anims.has_method("pop_in"):
		anims.call("pop_in", title_label, 0.28, Vector2(0.85, 0.85), 0.0)
	if anims and anims.has_method("fade_in"):
		anims.call("fade_in", desc_label, 0.3, 0.1)
		anims.call("fade_in", flavor_label, 0.25, 0.05)
	if anims and anims.has_method("slide_in_from_bottom"):
		anims.call("slide_in_from_bottom", choices_container, 24.0, 0.3, 0.2)

func _transition_to(path: String) -> void:
	var transition = get_node_or_null("/root/SceneTransition")
	if transition and transition.has_method("change_scene"):
		transition.call("change_scene", path)
	else:
		get_tree().change_scene_to_file(path)
