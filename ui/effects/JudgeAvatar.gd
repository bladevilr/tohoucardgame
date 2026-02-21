extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var emotion_label: Label = $EmotionLabel

func _ready():
	pivot_offset = size / 2
	emotion_label.text = ""

func setup(judge_id: String) -> void:
	if judge_id and ArtDatabase:
		var portrait = ArtDatabase.get_judge_portrait(judge_id)
		if portrait:
			texture_rect.texture = portrait
		else:
			push_warning("评委头像未找到: %s" % judge_id)

func react_to_impact(flavor: float):
	# 物理受击：缩放弹跳
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# 表情反馈
	if flavor > 40:
		show_emotion("😍")
	elif flavor > 20:
		show_emotion("😋")
	else:
		show_emotion("🙂")

func update_status(greasy: int, fatigue: int):
	# 状态反馈：变色或冒汗
	if greasy > 5:
		texture_rect.modulate = Color(0.8, 0.9, 0.6) # 发绿
		show_emotion("🤢")
	elif fatigue > 5:
		texture_rect.modulate = Color(0.7, 0.7, 0.7) # 灰暗
		show_emotion("😴")
	else:
		texture_rect.modulate = Color.WHITE

func show_emotion(emoji: String):
	emotion_label.text = emoji
	emotion_label.modulate.a = 1.0
	emotion_label.position.y = -20
	
	var tween = create_tween()
	tween.tween_property(emotion_label, "position:y", -60.0, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(emotion_label, "modulate:a", 0.0, 0.8)
