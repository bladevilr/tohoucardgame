extends CanvasLayer
class_name EventPopup

## 大巴扎风格事件弹窗 — 显示事件描述 + 可见的奖励选项（气泡形式）

signal choice_selected(choice_data: Dictionary, choice_index: int)
signal popup_closed()

const BubbleItemScene = preload("res://ui/components/BubbleItem.tscn")

var event_data: Dictionary = {}
var choice_bubbles: Array = []

@onready var overlay: ColorRect = $Overlay
@onready var popup_panel: PanelContainer = $PopupPanel
@onready var event_icon: TextureRect = $PopupPanel/VBox/EventIcon
@onready var event_title: Label = $PopupPanel/VBox/EventTitle
@onready var event_description: Label = $PopupPanel/VBox/EventDescription
@onready var choices_container: HBoxContainer = $PopupPanel/VBox/ChoicesContainer
@onready var close_button: Button = $PopupPanel/VBox/CloseButton

func _ready() -> void:
	layer = 100
	visible = false
	if overlay:
		overlay.gui_input.connect(_on_overlay_input)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)

func show_event(data: Dictionary) -> void:
	event_data = data
	_update_display()
	visible = true
	_animate_in()

func _update_display() -> void:
	# 设置事件图标
	if event_icon:
		var icon_path = "res://assets/events/%s.png" % event_data.get("icon", "merchant")
		var icon_texture = load(icon_path) if ResourceLoader.exists(icon_path) else null
		if icon_texture:
			event_icon.texture = icon_texture

	# 设置标题
	if event_title:
		event_title.text = event_data.get("name", "事件")
		event_title.add_theme_font_size_override("font_size", 28)
		event_title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.4))

	# 设置描述
	if event_description:
		event_description.text = event_data.get("description", "")
		event_description.add_theme_font_size_override("font_size", 16)
		event_description.add_theme_color_override("font_color", Color(0.95, 0.92, 1.0))
		event_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# 创建选项气泡
	_build_choice_bubbles()

func _build_choice_bubbles() -> void:
	# 清除旧气泡
	for bubble in choice_bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	choice_bubbles.clear()

	if not choices_container:
		return

	var choices: Array = event_data.get("choices", [])
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		if choice.is_empty():
			continue

		var bubble: BubbleItem
		if ResourceLoader.exists("res://ui/components/BubbleItem.tscn"):
			bubble = BubbleItemScene.instantiate()
		else:
			bubble = BubbleItem.new()
			_setup_bubble_manually(bubble)

		var bubble_type = "reward"
		if choice.has("items"):
			bubble_type = "dish"
		bubble.setup(choice, bubble_type)
		bubble.bubble_clicked.connect(_on_choice_clicked.bind(i))
		choices_container.add_child(bubble)
		choice_bubbles.append(bubble)

		# 入场动画
		bubble.modulate.a = 0.0
		bubble.scale = Vector2(0.5, 0.5)
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(bubble, "modulate:a", 1.0, 0.3).set_delay(0.3 + i * 0.15)
		tween.parallel().tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.3).set_delay(0.3 + i * 0.15)

func _setup_bubble_manually(bubble: BubbleItem) -> void:
	var bg := Panel.new()
	bg.name = "BubbleBackground"
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bubble.add_child(bg)

	var icon := TextureRect.new()
	icon.name = "ItemIcon"
	icon.set_anchors_preset(Control.PRESET_CENTER)
	icon.custom_minimum_size = Vector2(80, 80)
	icon.position = Vector2(-40, -50)
	bubble.add_child(icon)

	var name_lbl := Label.new()
	name_lbl.name = "ItemName"
	name_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name_lbl.offset_left = 0
	name_lbl.offset_top = -30
	name_lbl.offset_right = 0
	name_lbl.offset_bottom = -10
	bubble.add_child(name_lbl)

	var cost_lbl := Label.new()
	cost_lbl.name = "CostLabel"
	cost_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	cost_lbl.offset_left = 0
	cost_lbl.offset_top = -10
	cost_lbl.offset_right = 0
	cost_lbl.offset_bottom = 10
	bubble.add_child(cost_lbl)

	var glow := ColorRect.new()
	glow.name = "GlowEffect"
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.z_index = -1
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bubble.add_child(glow)

func _animate_in() -> void:
	if popup_panel:
		popup_panel.modulate.a = 0.0
		popup_panel.scale = Vector2(0.8, 0.8)
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(popup_panel, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(popup_panel, "scale", Vector2(1.0, 1.0), 0.3)

func _animate_out() -> void:
	if popup_panel:
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(popup_panel, "modulate:a", 0.0, 0.2)
		tween.parallel().tween_property(popup_panel, "scale", Vector2(0.8, 0.8), 0.2)
		tween.tween_callback(func(): visible = false)

func _on_choice_clicked(choice_index: int) -> void:
	if choice_index < 0 or choice_index >= event_data.get("choices", []).size():
		return
	var choice = event_data.get("choices", [])[choice_index]
	choice_selected.emit(choice, choice_index)
	_animate_out()

func _on_close_pressed() -> void:
	popup_closed.emit()
	_animate_out()

func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# 点击遮罩层关闭（可选）
			pass
