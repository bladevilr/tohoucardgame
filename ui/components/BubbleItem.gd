extends Control
class_name BubbleItem

## 大巴扎风格气泡物品 — 半透明球形泡泡显示物品/头像

signal bubble_clicked()
signal bubble_hovered(hovered: bool)

var item_data: Dictionary = {}
var bubble_type: String = "dish"  # dish, tool, event, reward

var bubble_bg: Panel
var item_icon: TextureRect
var item_name: Label
var cost_label: Label
var glow_effect: ColorRect
var hover_desc_label: Label  # 悬停时显示的描述文字
var _icon_placeholder: ColorRect

const BUBBLE_SIZE := Vector2(120, 120)
const HOVER_SCALE := 1.15
const NORMAL_SCALE := 1.0

func _ready() -> void:
	custom_minimum_size = BUBBLE_SIZE
	z_index = 10  # 设置高 z_index
	_create_ui_nodes()
	_setup_bubble_style()
	_setup_signals()

	print("BubbleItem ready, z_index: ", z_index, ", size: ", custom_minimum_size)

func _create_ui_nodes() -> void:
	# 如果场景文件存在，节点已经创建好了
	bubble_bg = get_node_or_null("BubbleBackground")
	item_icon = get_node_or_null("ItemIcon")
	item_name = get_node_or_null("ItemName")
	cost_label = get_node_or_null("CostLabel")
	glow_effect = get_node_or_null("GlowEffect")

	# 如果节点不存在，手动创建
	if bubble_bg == null:
		bubble_bg = Panel.new()
		bubble_bg.name = "BubbleBackground"
		bubble_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(bubble_bg)

	if glow_effect == null:
		glow_effect = ColorRect.new()
		glow_effect.name = "GlowEffect"
		glow_effect.set_anchors_preset(Control.PRESET_FULL_RECT)
		glow_effect.z_index = -1
		glow_effect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(glow_effect)
		move_child(glow_effect, 0)

	if item_icon == null:
		item_icon = TextureRect.new()
		item_icon.name = "ItemIcon"
		# 用 FULL_RECT + 边距让图标填满气泡中心区域
		item_icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		item_icon.offset_left = 15
		item_icon.offset_top = 10
		item_icon.offset_right = -15
		item_icon.offset_bottom = -30  # 底部留空给文字
		item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(item_icon)

	if item_name == null:
		item_name = Label.new()
		item_name.name = "ItemName"
		item_name.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		item_name.offset_left = 0
		item_name.offset_top = -30
		item_name.offset_right = 0
		item_name.offset_bottom = -10
		item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(item_name)

	if cost_label == null:
		cost_label = Label.new()
		cost_label.name = "CostLabel"
		cost_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		cost_label.offset_left = 0
		cost_label.offset_top = -10
		cost_label.offset_right = 0
		cost_label.offset_bottom = 10
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(cost_label)

	# 悬停描述标签（初始隐藏）
	if hover_desc_label == null:
		hover_desc_label = Label.new()
		hover_desc_label.name = "HoverDescLabel"
		hover_desc_label.set_anchors_preset(Control.PRESET_CENTER)
		hover_desc_label.position = Vector2(-80, 80)  # 气泡下方
		hover_desc_label.custom_minimum_size = Vector2(160, 40)
		hover_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hover_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hover_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hover_desc_label.add_theme_font_size_override("font_size", 13)
		hover_desc_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		hover_desc_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
		hover_desc_label.add_theme_constant_override("outline_size", 7)
		hover_desc_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
		hover_desc_label.add_theme_constant_override("shadow_offset_x", 1)
		hover_desc_label.add_theme_constant_override("shadow_offset_y", 2)
		hover_desc_label.visible = false
		add_child(hover_desc_label)

func setup(data: Dictionary, type: String = "dish") -> void:
	item_data = data
	bubble_type = type
	# 延迟到节点树准备好后再更新显示
	if is_inside_tree():
		_update_display()
	else:
		call_deferred("_update_display")

func _setup_bubble_style() -> void:
	if not bubble_bg:
		return

	# 使用气泡图片素材作为背景
	var frame_tex = load("res://assets/ui/bubble/bubble_frame.png")
	if frame_tex:
		# Panel 背景设为透明
		var empty_style = StyleBoxEmpty.new()
		bubble_bg.add_theme_stylebox_override("panel", empty_style)

		# 添加 TextureRect 显示气泡图片
		var bg_tex = bubble_bg.get_node_or_null("BubbleFrameTex")
		if bg_tex == null:
			bg_tex = TextureRect.new()
			bg_tex.name = "BubbleFrameTex"
			bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
			bg_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			bg_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			bg_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bubble_bg.add_child(bg_tex)
			bubble_bg.move_child(bg_tex, 0)
		bg_tex.texture = frame_tex

	# 底部文字区域加深色半透明背景，提升可读性
	var text_bg = get_node_or_null("TextBackground")
	if text_bg == null:
		text_bg = ColorRect.new()
		text_bg.name = "TextBackground"
		text_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		text_bg.offset_top = -36.0
		text_bg.offset_bottom = 2.0
		text_bg.color = Color(0.0, 0.0, 0.0, 0.55)
		text_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(text_bg)
		# 确保文字在背景上方
		if item_name:
			move_child(item_name, get_child_count() - 1)
		if cost_label:
			move_child(cost_label, get_child_count() - 1)

	# 发光效果（默认隐藏）
	if glow_effect:
		glow_effect.color = Color(0.8, 0.6, 1.0, 0.0)
		glow_effect.visible = false

func _setup_signals() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func _update_display() -> void:
	if item_data.is_empty():
		return

	if item_icon:
		var icon_texture: Texture2D = _resolve_icon_texture()
		if icon_texture:
			item_icon.texture = icon_texture
			item_icon.visible = true
			if _icon_placeholder and is_instance_valid(_icon_placeholder):
				_icon_placeholder.queue_free()
				_icon_placeholder = null
		else:
			# 使用占位符颜色块
			item_icon.visible = false
			if _icon_placeholder == null or not is_instance_valid(_icon_placeholder):
				_icon_placeholder = ColorRect.new()
				_icon_placeholder.color = Color(0.5, 0.4, 0.6, 0.8)
				_icon_placeholder.set_anchors_preset(Control.PRESET_CENTER)
				_icon_placeholder.custom_minimum_size = Vector2(60, 60)
				_icon_placeholder.position = Vector2(-30, -40)
				_icon_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(_icon_placeholder)

	# 设置名称
	if item_name:
		var display_name: String = ""
		match bubble_type:
			"dish", "tool":
				display_name = str(item_data.get("name_cn", item_data.get("name", "???")))
			"event":
				display_name = str(item_data.get("name", "???"))
			"reward":
				display_name = str(item_data.get("label", "???"))
		item_name.text = display_name
		item_name.add_theme_font_size_override("font_size", 12)
		item_name.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		item_name.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
		item_name.add_theme_constant_override("outline_size", 6)
		item_name.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
		item_name.add_theme_constant_override("shadow_offset_x", 1)
		item_name.add_theme_constant_override("shadow_offset_y", 1)
		item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 设置价格/数量
	if cost_label:
		var cost_text: String = ""
		if item_data.has("cost"):
			cost_text = "%d金" % int(item_data.get("cost", 0))
		elif item_data.has("amount"):
			cost_text = "×%d" % int(item_data.get("amount", 0))
		cost_label.text = cost_text
		cost_label.add_theme_font_size_override("font_size", 14)
		cost_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.4))
		cost_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
		cost_label.add_theme_constant_override("outline_size", 6)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 设置悬停描述文字
	if hover_desc_label:
		var desc_text: String = str(item_data.get("description", ""))
		hover_desc_label.text = desc_text

	# 根据品质设置边框颜色
	if item_data.has("tier") and bubble_bg:
		var tier: int = int(item_data.get("tier", 0))
		var tier_colors: Dictionary = {
			0: Color(0.6, 0.6, 0.6, 0.6),      # Bronze
			1: Color(0.75, 0.75, 0.85, 0.7),   # Silver
			2: Color(1.0, 0.85, 0.3, 0.8),     # Gold
			3: Color(0.8, 0.4, 1.0, 0.9)       # Diamond
		}
		var style: StyleBox = bubble_bg.get_theme_stylebox("panel")
		if style and style is StyleBoxFlat:
			(style as StyleBoxFlat).border_color = tier_colors.get(tier, Color(0.65, 0.55, 0.85, 0.6))

func _resolve_icon_texture() -> Texture2D:
	var item_id: String = str(item_data.get("id", ""))
	match bubble_type:
		"dish":
			if item_id != "":
				return ArtDatabase.get_dish_icon(item_id)
		"tool":
			if item_id != "":
				return ArtDatabase.get_tool_icon(item_id)
		"event":
			return _load_texture_from_paths([
				"res://assets/ui/chefs/%s.png" % str(item_data.get("icon", "")),
				"res://assets/merchants/%s.png" % str(item_data.get("icon", "")),
				"res://assets/ui/chefs/reimu.png",
			])
		"reward":
			var reward_icon: String = str(item_data.get("icon", ""))
			return _load_texture_from_paths([
				"res://assets/ui/rewards/%s.png" % reward_icon,
				"res://assets/ui/dishes/%s.png" % reward_icon,
				"res://assets/ui/tools/%s.png" % reward_icon,
				"res://assets/ui/ingredients/%s.png" % reward_icon,
			])
	return null

func _load_texture_from_paths(paths: Array[String]) -> Texture2D:
	for path in paths:
		if path == "":
			continue
		if ResourceLoader.exists(path):
			# Some *.import files in this project are marked valid=false.
			# When that happens, loading through ResourceLoader can fail even if source PNG exists.
			if not _is_marked_invalid_import(path):
				var tex: Texture2D = load(path) as Texture2D
				if tex:
					return tex
		var raw_tex: Texture2D = _load_raw_image_texture(path)
		if raw_tex:
			return raw_tex
	return null

func _is_marked_invalid_import(res_path: String) -> bool:
	if not res_path.begins_with("res://"):
		return false
	var import_sidecar := "%s.import" % res_path
	if not FileAccess.file_exists(import_sidecar):
		return false
	var f := FileAccess.open(import_sidecar, FileAccess.READ)
	if f == null:
		return false
	var content := f.get_as_text()
	return content.find("valid=false") >= 0

func _load_raw_image_texture(res_path: String) -> Texture2D:
	if not res_path.begins_with("res://"):
		return null
	var abs_path := ProjectSettings.globalize_path(res_path)
	if not FileAccess.file_exists(abs_path):
		return null
	var img := Image.new()
	var err := img.load(abs_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(img)

func _on_mouse_entered() -> void:
	bubble_hovered.emit(true)
	_animate_hover(true)

func _on_mouse_exited() -> void:
	bubble_hovered.emit(false)
	_animate_hover(false)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			bubble_clicked.emit()
			_animate_click()

func _animate_hover(hovered: bool) -> void:
	var target_scale := HOVER_SCALE if hovered else NORMAL_SCALE
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), 0.2)

	# 发光效果
	if glow_effect:
		glow_effect.visible = hovered
		if hovered:
			var glow_tween := create_tween()
			glow_tween.tween_property(glow_effect, "color:a", 0.3, 0.2)

	# 显示/隐藏描述文字
	if hover_desc_label:
		hover_desc_label.visible = hovered
		if hovered:
			hover_desc_label.modulate.a = 0.0
			var desc_tween := create_tween()
			desc_tween.tween_property(hover_desc_label, "modulate:a", 1.0, 0.2)

func _animate_click() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.1)

func set_enabled(enabled: bool) -> void:
	mouse_filter = MOUSE_FILTER_STOP if enabled else MOUSE_FILTER_IGNORE
	modulate.a = 1.0 if enabled else 0.5
