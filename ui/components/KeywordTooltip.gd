extends PanelContainer

@onready var color_bar: ColorRect = $ColorBar
@onready var name_label: Label = $VBox/NameLabel
@onready var type_label: Label = $VBox/TypeLabel
@onready var desc_label: Label = $VBox/DescLabel
@onready var stacks_label: Label = $VBox/StacksLabel

var _show_timer: Timer
var _pending_kw: Dictionary = {}

func _ready() -> void:
	_show_timer = Timer.new()
	_show_timer.one_shot = true
	_show_timer.wait_time = 0.2
	_show_timer.timeout.connect(_on_show_timer_timeout)
	add_child(_show_timer)
	visible = false

func show_keyword(keyword_id: String, stacks: int = 0):
	var kw = KeywordDatabase.get_keyword(keyword_id)
	if kw.is_empty():
		hide_tooltip()
		return
	_pending_kw = {
		"id": keyword_id,
		"stacks": stacks,
		"kw": kw,
	}
	_show_timer.start()

func _on_show_timer_timeout() -> void:
	if _pending_kw.is_empty():
		return
	var kw: Dictionary = _pending_kw.get("kw", {})
	var pending_id = str(_pending_kw.get("id", ""))
	name_label.text = "[%s]" % kw.get("name", pending_id)
	desc_label.text = kw.get("description", "")

	var kw_type = str(kw.get("type", ""))
	match kw_type:
		"buff":
			type_label.text = "增益"
			color_bar.color = Color(0.22, 0.78, 0.35)
		"environment":
			type_label.text = "环境"
			color_bar.color = Color(0.86, 0.30, 0.28)
		"mark":
			type_label.text = "标记"
			color_bar.color = Color(0.60, 0.36, 0.86)
		_:
			type_label.text = ""
			color_bar.color = Color(0.6, 0.6, 0.6)

	var stacks = int(_pending_kw.get("stacks", 0))
	stacks_label.text = "层数: %d" % stacks if stacks > 0 else ""
	stacks_label.visible = stacks > 0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.09, 0.14, 0.97)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = color_bar.color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 8
	add_theme_stylebox_override("panel", style)

	visible = true
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.15)

func hide_tooltip():
	_pending_kw.clear()
	if _show_timer:
		_show_timer.stop()
	visible = false
