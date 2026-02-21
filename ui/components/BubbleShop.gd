extends Control
class_name BubbleShop

## 大巴扎风格气泡商店 — 替换原有的 ShopPanel

signal item_selected(item_data: Dictionary, bubble_index: int)
signal refresh_requested()

var bubbles: Array[Control] = []
var shop_items: Array[Dictionary] = []

var bubble_container: HBoxContainer
var refresh_button: Button
var gold_label: Label

func _ready() -> void:
	_create_ui_nodes()
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)
	_setup_style()

func _create_ui_nodes() -> void:
	# 创建主容器
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)

	# 顶部信息栏（金币显示）
	var top_bar := HBoxContainer.new()
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(top_bar)

	gold_label = Label.new()
	gold_label.text = "金币: 0"
	gold_label.add_theme_font_size_override("font_size", 18)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	top_bar.add_child(gold_label)

	# 气泡容器
	bubble_container = HBoxContainer.new()
	bubble_container.alignment = BoxContainer.ALIGNMENT_CENTER
	bubble_container.add_theme_constant_override("separation", 20)
	bubble_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bubble_container.custom_minimum_size = Vector2(0, 150)  # 确保有足够高度
	vbox.add_child(bubble_container)

	# 底部按钮栏
	var bottom_bar := HBoxContainer.new()
	bottom_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_bar.custom_minimum_size = Vector2(0, 50)
	vbox.add_child(bottom_bar)

	refresh_button = Button.new()
	refresh_button.text = "刷新商店"
	refresh_button.custom_minimum_size = Vector2(120, 40)
	bottom_bar.add_child(refresh_button)

	print("BubbleShop UI nodes created: vbox=%s, bubble_container=%s" % [vbox.get_path(), bubble_container.get_path()])

func _setup_style() -> void:
	# 设置自身 z_index
	z_index = 100

	# 背景半透明（改为更明显的颜色用于调试）
	var bg := ColorRect.new()
	bg.color = Color(0.2, 0.15, 0.3, 0.8)  # 更明显的紫色背景
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	add_child(bg)
	move_child(bg, 0)

	print("BubbleShop background added with color: ", bg.color)
	print("BubbleShop z_index set to: ", z_index)

	# 刷新按钮样式
	if refresh_button:
		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = Color(0.25, 0.20, 0.35, 0.9)
		btn_style.border_width_left = 1
		btn_style.border_width_top = 1
		btn_style.border_width_right = 1
		btn_style.border_width_bottom = 1
		btn_style.border_color = Color(0.65, 0.55, 0.85, 0.7)
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_right = 8
		btn_style.corner_radius_bottom_left = 8
		refresh_button.add_theme_stylebox_override("normal", btn_style)
		refresh_button.add_theme_color_override("font_color", Color(0.95, 0.92, 1.0))

func display_shop(items: Array, player_gold: int = 0) -> void:
	shop_items.clear()
	for entry in items:
		if entry is Dictionary:
			shop_items.append(entry)
	_rebuild_bubbles()
	if gold_label:
		gold_label.text = "金币: %d" % player_gold

	print("BubbleShop.display_shop called with %d items, gold: %d" % [items.size(), player_gold])

const ItemCardScene = preload("res://ui/components/ItemCard.tscn")

### 部分代码省略...

func _rebuild_bubbles() -> void:
	# 清除旧气泡
	for bubble in bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	bubbles.clear()

	if not bubble_container:
		print("BubbleShop: bubble_container is null!")
		return

	print("BubbleShop: Creating %d item cards" % shop_items.size())

	# 创建新卡牌
	for i in range(shop_items.size()):
		var item: Dictionary = shop_items[i]
		if item.is_empty():
			continue

		var card: Control = null
		if ItemCardScene:
			var card_node: Node = ItemCardScene.instantiate()
			card = card_node as Control
		else:
			print("ItemCardScene not found!")
			continue
		if card == null:
			continue

		# 设置卡牌数据
		bubble_container.add_child(card)
		if card.has_method("setup"):
			card.call("setup", item)
		
		# 禁用部分交互，使其适应商店点击逻辑
		# ItemCard 内部有 _gui_input 处理点击，我们需要连接它的 clicked 信号
		if card.has_signal("card_clicked"):
			card.connect("card_clicked", Callable(self, "_on_card_clicked").bind(i))
		
		# 存入列表
		bubbles.append(card)

		# 入场动画
		card.modulate.a = 0.0
		card.scale = Vector2(0.5, 0.5)
		# 确保卡牌以中心为缩放点
		card.pivot_offset = card.size / 2
		
		var tween := create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(card, "modulate:a", 1.0, 0.3).set_delay(i * 0.1)
		tween.parallel().tween_property(card, "scale", Vector2(0.8, 0.8), 0.3).set_delay(i * 0.1) # 商店里稍微小一点

func _on_card_clicked(_item_data_unused: Variant, card_index: int) -> void:
	if card_index < 0 or card_index >= shop_items.size():
		return
	var item: Dictionary = shop_items[card_index]
	item_selected.emit(item, card_index)
	# 点击动画
	if card_index < bubbles.size():
		var card: Control = bubbles[card_index]
		var tween := create_tween()
		tween.tween_property(card, "scale", Vector2(0.7, 0.7), 0.1)
		tween.tween_property(card, "scale", Vector2(0.8, 0.8), 0.1)


func _on_refresh_pressed() -> void:
	refresh_requested.emit()

func set_bubble_enabled(bubble_index: int, enabled: bool) -> void:
	if bubble_index >= 0 and bubble_index < bubbles.size():
		var bubble: Control = bubbles[bubble_index]
		if bubble and bubble.has_method("set_enabled"):
			bubble.call("set_enabled", enabled)
