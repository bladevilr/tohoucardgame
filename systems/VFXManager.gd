## VFX 管理器 (Visual Effects Manager)
##
## 全局单例，监听 SignalBus 事件。
## 根据事件在对应位置生成粒子、播放动画、应用 Shader。
##
## 需要在 Godot 编辑器中将此脚本设为 Autoload。

extends Node

## 特效节点容器 (运行时会自动创建)
var _fx_container: Node2D = null

## 环境效果追踪
var _env_overlays: Dictionary = {}# keyword -> overlay_node

func _ready():
	_fx_container = Node2D.new()
	_fx_container.name = "VFXContainer"
	_fx_container.z_index = 100
	add_child(_fx_container)
	_connect_signals()

func _connect_signals():
	if not SignalBus.has_signal("score_produced"):
		return
	SignalBus.score_produced.connect(_on_score_produced)
	SignalBus.keyword_gained.connect(_on_keyword_gained)
	SignalBus.keyword_environment_applied.connect(_on_environment_applied)
	SignalBus.keyword_environment_cleared.connect(_on_environment_cleared)
	if SignalBus.has_signal("prestige_changed"):
		SignalBus.prestige_changed.connect(_on_prestige_changed)

## ---------- 上菜得分特效 ----------
func _on_score_produced(player_idx: int, slot_idx: int, scores: Dictionary):
	var total = 0.0
	for v in scores.values():
		total += float(v)

	# 根据得分大小选择特效强度
	if total >= 30:
		_spawn_burst_fx(player_idx, slot_idx, Color.GOLD, 2.0)
	elif total >= 15:
		_spawn_burst_fx(player_idx, slot_idx, Color.ORANGE, 1.2)
	elif total > 0:
		_spawn_burst_fx(player_idx, slot_idx, Color.WHITE, 0.6)

## ---------- 关键词获得特效 ----------
func _on_keyword_gained(player_idx: int, slot_idx: int, keyword_id: String, stacks: int):
	var color := Color.CYAN
	match keyword_id:
		"umami":
			color = Color(1.0, 0.85, 0.2)  # 黄色-提味
		"plating":
			color = Color(0.3, 0.9, 0.4)   # 绿色-增色
		"knife_work":
			color = Color(0.5, 0.8, 1.0)   # 浅蓝-精技
		"spotlight":
			color = Color(0.3, 0.9, 0.9)   # 青色-加速
		"rich":
			color = Color(0.6, 0.2, 0.1)  # 深棕-浓郁
		"aftertaste":
			color = Color(0.9, 0.5, 0.7)  # 粉色-回味

	if stacks >= 3:
		_spawn_burst_fx(player_idx, slot_idx, color, 1.5)
	else:
		_spawn_ring_fx(player_idx, slot_idx, color)

## ---------- 环境恶化特效 ----------
func _on_environment_applied(keyword_id: String, stacks: int, player_idx: int):
	match keyword_id:
		"greasy":
			_apply_screen_overlay("greasy", Color(0.4, 0.3, 0.1, mini(stacks, 5) * 0.06))
		"taste_fatigue":
			_apply_screen_overlay("taste_fatigue", Color(0.5, 0.5, 0.5, mini(stacks, 5) * 0.05))
		"messy":
			_apply_screen_overlay("messy", Color(0.3, 0.2, 0.1, mini(stacks, 5) * 0.04))
		"dull":
			_apply_screen_overlay("dull", Color(0.4, 0.4, 0.6, mini(stacks, 5) * 0.05))

func _on_environment_cleared(keyword_id: String, amount: int):
	if _env_overlays.has(keyword_id):
		var overlay = _env_overlays[keyword_id]
		if is_instance_valid(overlay):
			# Fade out
			var tween = create_tween()
			tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
			tween.tween_callback(overlay.queue_free)
		_env_overlays.erase(keyword_id)

## ---------- 声望变化特效 ----------
func _on_prestige_changed(player_idx: int, old_val: int, new_val: int):
	if new_val < old_val:
		# 受到伤害 - 屏幕闪红
		_flash_screen(Color(1, 0, 0, 0.3), 0.4)
		if new_val <= 2:
			# 濒死 - 持续红色脉动
			_flash_screen(Color(1, 0, 0, 0.15), 1.0)


## ============ 特效工厂 ============

func _spawn_burst_fx(player_idx: int, slot_idx: int, color: Color, scale: float = 1.0):
	## 爆发粒子 (圆形扩散)
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = roundi(12 * scale)
	particles.lifetime = 0.6
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.initial_velocity_min = 60.0 * scale
	particles.initial_velocity_max = 120.0 * scale
	particles.gravity = Vector2(0, 150)
	particles.scale_amount_min = 2.0 * scale
	particles.scale_amount_max = 4.0 * scale
	particles.color = color
	# 位置: 简单按 slot 计算, 需要根据实际UI布局调整
	particles.position = _slot_to_screen_pos(player_idx, slot_idx)
	_fx_container.add_child(particles)
	# 自动清理
	get_tree().create_timer(1.5).timeout.connect(func():
		if is_instance_valid(particles):
			particles.queue_free())

func _spawn_ring_fx(player_idx: int, slot_idx: int, color: Color):
	## 光环扩散 (简单用 ColorRect 模拟，实际项目可替换为Sprite)
	var ring = ColorRect.new()
	ring.color = color
	ring.color.a = 0.6
	ring.size = Vector2(20, 20)
	ring.position = _slot_to_screen_pos(player_idx, slot_idx) - Vector2(10, 10)
	ring.pivot_offset = Vector2(10, 10)
	_fx_container.add_child(ring)

	var tween = create_tween()
	tween.tween_property(ring, "scale", Vector2(3, 3), 0.4).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, 0.4)
	tween.tween_callback(ring.queue_free)

func _apply_screen_overlay(keyword_id: String, color: Color):
	if _env_overlays.has(keyword_id) and is_instance_valid(_env_overlays[keyword_id]):
		# 更新颜色
		_env_overlays[keyword_id].color = color
		return

	var overlay = ColorRect.new()
	overlay.color = color
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.name = "EnvOverlay_%s" % keyword_id
	# 需要挂在 CanvasLayer 上才能覆盖全屏
	add_child(overlay)
	_env_overlays[keyword_id] = overlay

func _flash_screen(color: Color, duration: float):
	var flash = ColorRect.new()
	flash.color = color
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.anchors_preset = Control.PRESET_FULL_RECT
	add_child(flash)
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, duration)
	tween.tween_callback(flash.queue_free)

func _slot_to_screen_pos(player_idx: int, slot_idx: int) -> Vector2:
	## 将 (player_idx, slot_idx) 映射到屏幕坐标
	## 这里给出一个合理的默认值, 需要根据实际UI布局微调
	var base_x = 100.0 if player_idx == 0 else 600.0
	var base_y = 300.0
	return Vector2(base_x + slot_idx * 80.0, base_y)
