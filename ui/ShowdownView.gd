extends Control

const ItemCardScene = preload("res://ui/components/ItemCard.tscn")
const DishProjectileScene = preload("res://ui/effects/DishProjectile.tscn")
const FloatingTextScript = preload("res://ui/effects/FloatingText.gd")
const ItemTooltipScene = preload("res://ui/components/ItemTooltip.tscn")
const CardInspectorScene = preload("res://ui/views/CardInspector.tscn")

const CHEF_NAME_MAP := {
	"mystia": "米斯蒂娅",
	"sakuya": "十六夜咲夜",
	"youmu": "魂魄妖梦",
	"meiling": "红美铃",
	"marisa": "雾雨魔理沙",
	"reimu": "博丽灵梦",
	"alice": "爱丽丝",
	"patchouli": "帕秋莉",
	"reisen": "铃仙",
	"seija": "鬼人正邪"
}

const KEYWORD_NAME_MAP := {
	"umami": "鲜美",
	"char_aroma": "焦香",
	"plating": "摆盘",
	"knife_work": "刀工",
	"aftertaste": "回味",
	"secret_recipe": "秘方",
	"spotlight": "高光",
	"greasy": "腻口",
	"messy": "杂乱",
	"taste_fatigue": "味觉疲劳",
	"dull": "寡淡",
	# 新引擎机制
	"appetizing": "开胃",
	"addictive": "上瘾",
	"sizzling": "爆香",
	"crisp": "爽脆",
	"refreshing": "清口",
	"fermented": "发酵",
}

const BUFF_KEYWORDS := ["umami", "char_aroma", "plating", "knife_work", "aftertaste", "secret_recipe", "spotlight"]
const DEBUFF_KEYWORDS := ["greasy", "messy", "taste_fatigue", "dull"]

const BROADCAST_COLORS := {
	"serve_epic": Color(0.2, 1.0, 0.95),
	"serve_great": Color(0.3, 0.9, 0.85),
	"serve": Color(0.3, 0.85, 0.9),
	"serve_weak": Color(0.3, 0.6, 0.7),
	"combo": Color(1, 0.6, 0.2),
	"chef_skill": Color(0.6, 0.9, 1.0),
	"keyword": Color(0.4, 1.0, 0.5),
	"synergy": Color(0.5, 1.0, 0.4),
	"environment": Color(1.0, 0.3, 0.3),
	"lead": Color(1, 1, 0.4),
	"comeback": Color(1, 0.4, 0.4),
	"result": Color(1, 0.9, 0.4),
	"clash": Color(1.0, 0.9, 0.2),
	"clash_warning": Color(1.0, 0.7, 0.1)
}

@onready var background: TextureRect = $Background
@onready var timer_label: Label = $MainHBox/VBox/TopBar/TimerLabel
@onready var opponent_board: HBoxContainer = $MainHBox/VBox/OpponentArea/OpponentScroll/OpponentBoard
@onready var player_board: HBoxContainer = $MainHBox/VBox/PlayerArea/PlayerScroll/PlayerBoard
@onready var score_bar = $MainHBox/VBox/ScoreArea/ScoreBarRow/ScoreBar
@onready var judge_avatar = $CenterArea/JudgeAvatar
@onready var projectiles_layer = $ProjectilesLayer
@onready var chef_portrait_frame: PanelContainer = $ChefPortraitDock/ChefPortraitFrame
@onready var chef_portrait: TextureRect = $ChefPortraitDock/ChefPortraitFrame/ChefPortrait
@onready var opponent_badge: PanelContainer = $OpponentBadge
@onready var opponent_name_label: Label = $OpponentBadge/Margin/HBox/Info/OpponentNameLabel
@onready var opponent_portrait: TextureRect = $OpponentBadge/Margin/HBox/OpponentPortrait
@onready var broadcast_scroll: ScrollContainer = $MainHBox/BroadcastPanel/BroadcastScroll
@onready var broadcast_log: VBoxContainer = $MainHBox/BroadcastPanel/BroadcastScroll/BroadcastLog
@onready var broadcast_panel: PanelContainer = $MainHBox/BroadcastPanel
@onready var player_keyword_row: HBoxContainer = $MainHBox/VBox/PlayerArea/PlayerKeywordRow
@onready var opponent_keyword_row: HBoxContainer = $MainHBox/VBox/OpponentArea/OpponentKeywordRow
@onready var env_keyword_row: HBoxContainer = $MainHBox/VBox/ScoreArea/EnvKeywordRow
@onready var technique_label: Label = $MainHBox/VBox/ScoreArea/BattleInfoPanel/BattleInfoRow/TechniqueLabel
@onready var aroma_label: Label = $MainHBox/VBox/ScoreArea/BattleInfoPanel/BattleInfoRow/AromaLabel
@onready var synergy_label: Label = $MainHBox/VBox/ScoreArea/BattleInfoPanel/BattleInfoRow/SynergyLabel

var _resolver: ShowdownResolver = null
var _resolver_v2: ShowdownResolverV2 = null
var _item_tooltip = null
var _broadcast_index: int = 0
var _judge_state_panel: VBoxContainer = null  # V2 评委状态面板

func _ready() -> void:
	_apply_aura_shader()
	_setup_chef_portrait()
	_setup_opponent_badge()
	_setup_judge_avatar()
	_setup_tooltip()
	_setup_broadcast_panel()

	var match_state = GameManager.get_match_state()
	if match_state == null:
		return

	if GameConfig.BATTLE_SYSTEM_V2:
		_setup_board_display(0, player_board)
		_setup_board_display(1, opponent_board)
		_setup_v2_judge_panel()
		ShowdownManager.start_showdown(match_state)
	else:
		_setup_board_display(0, player_board)
		_setup_board_display(1, opponent_board)
		ShowdownManager.start_showdown(match_state)
		_resolver = ShowdownManager.get_resolver()

	SignalBus.showdown_tick.connect(_on_tick)
	SignalBus.showdown_item_served.connect(_on_item_served)
	SignalBus.showdown_ended.connect(_on_showdown_ended)
	SignalBus.dot_tick.connect(_on_dot_tick)
	SignalBus.keyword_gained.connect(_on_keyword_gained)
	SignalBus.keyword_consumed.connect(_on_keyword_consumed)

func _setup_chef_portrait() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.08, 0.12, 0.72)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.40, 0.36, 0.55, 0.70)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 6
	style.content_margin_top = 6
	style.content_margin_right = 6
	style.content_margin_bottom = 6
	chef_portrait_frame.add_theme_stylebox_override("panel", style)

	var player = GameManager.get_player(0)
	if player == null:
		chef_portrait_frame.visible = false
		return

	chef_portrait.texture = ArtDatabase.get_chef_portrait(player.chef_id)
	chef_portrait_frame.visible = chef_portrait.texture != null

func _setup_opponent_badge() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.08, 0.12, 0.84)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.44, 0.48, 0.68, 0.82)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 8
	opponent_badge.add_theme_stylebox_override("panel", style)

	var enemy = GameManager.get_player(1)
	if enemy == null:
		opponent_badge.visible = false
		return

	var chef = ChefDatabase.get_chef(enemy.chef_id)
	opponent_name_label.text = _display_chef_name(enemy.chef_id, str(chef.get("name", "未知对手")))
	opponent_portrait.texture = ArtDatabase.get_chef_portrait(enemy.chef_id)
	opponent_badge.visible = true

func _setup_judge_avatar() -> void:
	# V2: 显示两位评委头像
	var match_state = GameManager.get_match_state()
	if match_state == null:
		return

	var judges = []
	if match_state.has_meta("judges"):
		judges = match_state.get_meta("judges")
	elif "judges" in match_state:
		judges = match_state.judges

	if judges.is_empty():
		push_warning("没有可用的评委信息")
		return

	# 如果只有一个 JudgeAvatar 节点，创建第二个
	var center_area = get_node_or_null("CenterArea")
	if center_area == null:
		return

	# 清理旧的评委头像
	for child in center_area.get_children():
		if child.name.begins_with("JudgeAvatar"):
			child.queue_free()

	# 创建两个评委头像
	var JudgeAvatarScene = load("res://ui/effects/JudgeAvatar.tscn")
	if JudgeAvatarScene == null:
		return

	var spacing = 140.0  # 两个头像之间的间距
	for i in range(mini(2, judges.size())):
		var j = judges[i]
		var judge_id: String = ""
		if j is Dictionary:
			judge_id = str(j.get("id", "")).to_lower()
		else:
			judge_id = str(j).to_lower()

		var avatar = JudgeAvatarScene.instantiate()
		avatar.name = "JudgeAvatar%d" % i
		center_area.add_child(avatar)

		# 左右并排放置
		var x_offset = -spacing / 2 if i == 0 else spacing / 2
		avatar.set_anchors_preset(Control.PRESET_CENTER)
		avatar.offset_left = x_offset - 60.0
		avatar.offset_top = -140.0
		avatar.offset_right = x_offset + 60.0
		avatar.offset_bottom = -20.0

		if avatar.has_method("setup"):
			avatar.setup(judge_id)

	# 保存第一个评委头像的引用（用于动画）
	judge_avatar = center_area.get_node_or_null("JudgeAvatar0")

func _apply_aura_shader() -> void:
	var shader = load("res://ui/shaders/presentation_war.gdshader")
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("balance", 0.5)
		mat.set_shader_parameter("intensity", 0.0)
		background.material = mat

func _setup_tooltip() -> void:
	_item_tooltip = ItemTooltipScene.instantiate()
	var layer := CanvasLayer.new()
	layer.layer = 150
	add_child(layer)
	layer.add_child(_item_tooltip)
	SignalBus.item_hovered.connect(func(data):
		if _item_tooltip and not data.is_empty():
			_item_tooltip.show_item(data, get_global_mouse_position())
	)
	SignalBus.item_unhovered.connect(func():
		if _item_tooltip:
			_item_tooltip.hide_tooltip()
	)

func _setup_board_display(player_idx: int, container: HBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

	var player: PlayerState = GameManager.get_player(player_idx)
	if player:
		for entry in player.get_board_items():
			var card = ItemCardScene.instantiate()
			container.add_child(card)
			card.setup(entry.item)
			card.set_meta("draggable", false)
			card.card_right_clicked.connect(_inspect_card)
			card.scale = Vector2(0.8, 0.8)
			card.custom_minimum_size = Vector2(160, 240) * 0.8

# ============================================================
#  V2: 评委状态面板
# ============================================================

func _setup_v2_judge_panel():
	"""创建 V2 评委状态显示面板"""
	_judge_state_panel = VBoxContainer.new()
	_judge_state_panel.name = "JudgeStatePanel"

	# 添加到 judge_avatar 旁边
	if judge_avatar and judge_avatar.get_parent():
		judge_avatar.get_parent().add_child(_judge_state_panel)
		_judge_state_panel.position = judge_avatar.position + Vector2(0, judge_avatar.size.y + 10)

	# 创建状态标签
	var satiety_label: Label = Label.new()
	satiety_label.name = "SatietyLabel"
	satiety_label.text = "饱腹: 0/100"
	_judge_state_panel.add_child(satiety_label)

	var mood_label: Label = Label.new()
	mood_label.name = "MoodLabel"
	mood_label.text = "心情: 0"
	_judge_state_panel.add_child(mood_label)

	var needs_label: Label = Label.new()
	needs_label.name = "NeedsLabel"
	needs_label.text = "需求: 无"
	needs_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	needs_label.custom_minimum_size = Vector2(200, 0)
	_judge_state_panel.add_child(needs_label)

func _update_v2_judge_panel(event: Dictionary):
	"""更新 V2 评委状态显示"""
	if not _judge_state_panel:
		return

	# 从 event 中读取评委状态（ShowdownResolverV2 需要在 event 中包含这些信息）
	var satiety: int = event.get("satiety", 0)
	var mood: int = event.get("mood", 0)
	var needs: Array = event.get("needs", [])

	var satiety_label: Label = _judge_state_panel.get_node_or_null("SatietyLabel")
	if satiety_label:
		satiety_label.text = "饱腹: %d" % satiety

	var mood_label: Label = _judge_state_panel.get_node_or_null("MoodLabel")
	if mood_label:
		var mood_text: String = "😊" if mood > 0 else "😐" if mood == 0 else "😠"
		mood_label.text = "心情: %s (%d)" % [mood_text, mood]

	var needs_label: Label = _judge_state_panel.get_node_or_null("NeedsLabel")
	if needs_label:
		if needs.is_empty():
			needs_label.text = "需求: 无"
		else:
			var need_names: Array = []
			for n in needs:
				need_names.append(n.get("type", ""))
			needs_label.text = "需求: " + ", ".join(need_names)

func _on_tick(elapsed: float) -> void:
	var remaining = maxf(0.0, GameConfig.SHOWDOWN_DURATION - elapsed)
	timer_label.text = "%d" % int(remaining)

	if GameConfig.BATTLE_SYSTEM_V2:
		var resolver_v2 = ShowdownManager.get_resolver_v2()
		if resolver_v2:
			var result = resolver_v2.get_result()
			if score_bar:
				score_bar.update_scores(result.score_a, result.score_b)
			# CD 条更新
			for p_idx in range(2):
				var container = player_board if p_idx == 0 else opponent_board
				var runtimes = resolver_v2.get_item_runtimes(p_idx)
				var cards = container.get_children()
				for i in range(mini(cards.size(), runtimes.size())):
					if cards[i].has_method("update_cd"):
						cards[i].update_cd(float(runtimes[i].current_cd))
	elif _resolver:
		var scores = _resolver.get_scores()
		score_bar.update_scores(scores[0], scores[1])

		var total = scores[0] + scores[1]
		if total > 1.0:
			var balance = scores[0] / total
			var mat = background.material as ShaderMaterial
			if mat:
				var curr = mat.get_shader_parameter("balance")
				mat.set_shader_parameter("balance", lerpf(curr, balance, 0.05))
				mat.set_shader_parameter("intensity", min(total / 500.0, 1.0))

		for p_idx in range(2):
			var container = player_board if p_idx == 0 else opponent_board
			var runtimes = _resolver.get_item_runtimes(p_idx)
			var cards = container.get_children()
			for i in range(mini(cards.size(), runtimes.size())):
				if cards[i].has_method("update_cd"):
					cards[i].update_cd(float(runtimes[i].current_cd))

		# 更新战斗信息面板
		_update_battle_info_panel()
		_poll_broadcast_log()
		_update_keyword_displays()

func _update_battle_info_panel() -> void:
	var match_state = GameManager.get_match_state()
	if match_state == null:
		return

	# 技法倍率 - 获取当前技法倍率加成
	var technique_multiplier = 1.0
	if match_state.has_meta("technique_multiplier"):
		technique_multiplier = float(match_state.get_meta("technique_multiplier"))
	elif "technique_multiplier" in match_state:
		technique_multiplier = float(match_state.technique_multiplier)
	technique_label.text = "技法倍率: %.2f×" % technique_multiplier

	# 香气加速 - 获取香气加成
	var aroma_acceleration = 1.0
	if match_state.has_meta("aroma_acceleration"):
		aroma_acceleration = float(match_state.get_meta("aroma_acceleration"))
	elif "aroma_acceleration" in match_state:
		aroma_acceleration = float(match_state.aroma_acceleration)
	aroma_label.text = "香气加速: %.2f×" % aroma_acceleration

	# 协同效应 - 获取协同百分比
	var synergy_percent = 0
	if match_state.has_meta("synergy_bonus"):
		synergy_percent = int(match_state.get_meta("synergy_bonus"))
	elif "synergy_bonus" in match_state:
		synergy_percent = int(match_state.synergy_bonus)
	synergy_label.text = "协同效应: %d%%" % synergy_percent

func _on_item_served(player_idx: int, item_idx: int, result: Dictionary) -> void:
	# V2: 更新评委状态面板
	if GameConfig.BATTLE_SYSTEM_V2:
		_update_v2_judge_panel(result)

	var container = player_board if player_idx == 0 else opponent_board
	var child_idx = _slot_to_child_idx(player_idx, item_idx)
	if child_idx < 0 or child_idx >= container.get_child_count():
		return

	var card = container.get_child(child_idx)
	var flavor: float = float(result.get("flavor", 0.0) if not GameConfig.BATTLE_SYSTEM_V2 else result.get("score", 0.0))
	var chain_mult: float = float(result.get("chain_mult", 1.0))
	var adjacent_links: int = int(result.get("adjacent_links", 0))

	var anims = get_node_or_null("/root/UIAnimations")
	if anims:
		anims.call("hover_lift", card, 0.9, 0.1)

	# Build base target point
	var start_pos = card.global_position + card.size * 0.5 * card.scale
	
	if adjacent_links > 0:
		FloatingTextScript.spawn(self, "连锁连击 ×%.1f" % chain_mult, start_pos + Vector2(0, -40), Color(1.0, 0.7, 0.2), 1.2, 70.0, 24)

	# 向两位评委发射菜品弹道
	var center_area = get_node_or_null("CenterArea")
	if center_area:
		for i in range(2):
			var avatar = center_area.get_node_or_null("JudgeAvatar%d" % i)
			if avatar == null:
				continue

			var proj = DishProjectileScene.instantiate()
			projectiles_layer.add_child(proj)
			var target = avatar.global_position + avatar.size * 0.5
			var served_item: Dictionary = result.get("item", {}) if not GameConfig.BATTLE_SYSTEM_V2 else result.get("dish", {})
			proj.launch(start_pos, target, flavor, served_item)

			# 延迟反应
			var delay = 0.5 + i * 0.1
			get_tree().create_timer(delay).timeout.connect(func():
				if avatar.has_method("react_to_impact"):
					avatar.react_to_impact(flavor)
			)

	var score_color = Color(1.0, 0.86, 0.35) if flavor > 30.0 else Color(0.6, 0.8, 1.0)
	FloatingTextScript.spawn(self, "+%d" % int(flavor), start_pos, score_color, 0.8, 60.0, 24)

func _on_dot_tick(player_idx: int, dot: float) -> void:
	score_bar.update_dot(dot, player_idx)

func _on_keyword_gained(player_idx: int, item_idx: int, kw_id: String, stacks: int) -> void:
	var kw_name = KEYWORD_NAME_MAP.get(kw_id, kw_id)
	var container = player_board if player_idx == 0 else opponent_board
	var child_idx = _slot_to_child_idx(player_idx, item_idx)
	var pos: Vector2
	if child_idx >= 0 and child_idx < container.get_child_count():
		var card = container.get_child(child_idx)
		pos = card.global_position + Vector2(card.size.x * 0.5 * card.scale.x, 0)
	else:
		pos = container.global_position + Vector2(container.size.x * 0.5, 0)
	var color = Color(0.4, 1.0, 0.6) if kw_id in BUFF_KEYWORDS else Color(1.0, 0.4, 0.4)
	FloatingTextScript.spawn(self, "+%d %s" % [stacks, kw_name], pos, color, 1.0, 50.0, 18)

func _on_keyword_consumed(player_idx: int, kw_id: String, amount: int) -> void:
	var kw_name = KEYWORD_NAME_MAP.get(kw_id, kw_id)
	var pos = score_bar.global_position + Vector2(score_bar.size.x * 0.5, 0)
	if player_idx == 1:
		pos.y -= 20.0
	var color = Color(1.0, 0.6, 0.3)
	FloatingTextScript.spawn(self, "-%d %s" % [amount, kw_name], pos, color, 1.0, 40.0, 18)

func _on_showdown_ended() -> void:
	await get_tree().create_timer(1.5).timeout
	var transition = get_node_or_null("/root/SceneTransition")
	if transition:
		transition.call("change_scene", "res://ui/ResultScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/ResultScreen.tscn")

func _slot_to_child_idx(player_idx: int, slot_idx: int) -> int:
	if GameConfig.BATTLE_SYSTEM_V2:
		# V2 tick mode: runtimes index matches card order
		var resolver_v2 = ShowdownManager.get_resolver_v2()
		if resolver_v2:
			var runtimes = resolver_v2.get_item_runtimes(player_idx)
			for i in range(runtimes.size()):
				if int(runtimes[i].slot_idx) == slot_idx:
					return i
		return slot_idx
	if _resolver == null:
		return slot_idx
	var runtimes = _resolver.get_item_runtimes(player_idx)
	for i in range(runtimes.size()):
		if int(runtimes[i].slot_idx) == slot_idx:
			return i
	return -1

func _inspect_card(item_data: Dictionary) -> void:
	var inspector = CardInspectorScene.instantiate()
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	layer.add_child(inspector)
	inspector.inspect_item(item_data)
	inspector.close_requested.connect(func(): layer.queue_free())

func _setup_broadcast_panel() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 0.85)
	style.border_width_left = 1
	style.border_color = Color(0.3, 0.3, 0.4, 0.6)
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	broadcast_panel.add_theme_stylebox_override("panel", style)

func _poll_broadcast_log() -> void:
	var log = _resolver.get_broadcast_log()
	var appended := false
	while _broadcast_index < log.size():
		var entry = log[_broadcast_index]
		_broadcast_index += 1
		var lbl := Label.new()
		lbl.text = entry.get("text", "")
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var entry_type: String = entry.get("type", "serve")
		lbl.add_theme_color_override("font_color", BROADCAST_COLORS.get(entry_type, Color(0.85, 0.85, 0.85)))
		broadcast_log.add_child(lbl)
		appended = true
	if appended:
		call_deferred("_scroll_broadcast_to_bottom")

func _scroll_broadcast_to_bottom() -> void:
	if not is_inside_tree():
		return
	var bar := broadcast_scroll.get_v_scroll_bar()
	if bar:
		broadcast_scroll.scroll_vertical = int(bar.max_value)

func _update_keyword_displays() -> void:
	_update_keyword_row(0, player_keyword_row)
	_update_keyword_row(1, opponent_keyword_row)
	_update_env_keyword_row()

func _update_keyword_row(player_idx: int, row: HBoxContainer) -> void:
	for child in row.get_children():
		child.queue_free()
	var player = GameManager.get_player(player_idx)
	if player == null:
		return
	for kw_id in KEYWORD_NAME_MAP:
		var stacks = player.get_keyword_stacks(kw_id)
		if stacks > 0:
			row.add_child(_create_keyword_badge(kw_id, stacks))

func _update_env_keyword_row() -> void:
	for child in env_keyword_row.get_children():
		child.queue_free()
	var match_state = GameManager.get_match_state()
	if match_state == null:
		return
	for kw_id in match_state.environment_keywords:
		var stacks = match_state.environment_keywords[kw_id]
		if stacks > 0:
			env_keyword_row.add_child(_create_keyword_badge(kw_id, stacks, Color(0.3, 0.5, 0.8)))

func _create_keyword_badge(kw_id: String, stacks: int, override_color: Color = Color(-1, -1, -1)) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	if override_color.r >= 0:
		style.bg_color = override_color
	elif kw_id in BUFF_KEYWORDS:
		style.bg_color = Color(0.15, 0.45, 0.2, 0.9)
	else:
		style.bg_color = Color(0.5, 0.15, 0.15, 0.9)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	panel.add_theme_stylebox_override("panel", style)
	var lbl := Label.new()
	var kw_name = KEYWORD_NAME_MAP.get(kw_id, kw_id)
	lbl.text = "%s ×%d" % [kw_name, stacks]
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	panel.add_child(lbl)
	return panel

func _display_chef_name(chef_id: String, fallback: String) -> String:
	if CHEF_NAME_MAP.has(chef_id):
		return CHEF_NAME_MAP[chef_id]
	return fallback
