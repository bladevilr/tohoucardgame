extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var emotion_label: Label = $EmotionLabel

var _judge_id: String = ""
var bubble: PanelContainer
var bubble_label: Label
var _bubble_tween: Tween

var _dialogues = {
	"yuyuko": {
		"high": ["好吃好吃！", "啊～满足～", "还有吗还有吗？"],
		"mid": ["嗯，还行吧。", "就这点啊...", "能吃。"],
		"low": ["这也太少了吧。", "不太行啊这个。"],
		"cleared_greasy": ["恰到好处的清爽！正好用来溜缝~", "吃完这个肚子里又腾出空间啦！", "清清爽爽，妖梦，再上一轮！"],
		"cleared_fatigue": ["味觉好像复苏了呢。继续继续！", "清新的味道重新唤醒了人家的食欲~"],
		"got_greasy": ["唔...好腻，妖梦，拿茶来——", "这也太油了吧，吃不下了啦..."],
		"got_fatigue": ["怎么吃着没味道了？太饱了吗...", "舌头麻木了，尝不出好坏了呢。"]
	},
	"yuuma": {
		"high": ["好吃！再来！", "不错不错！", "过瘾！"],
		"mid": ["还凑合。", "不够劲啊。", "就这？"],
		"low": ["什么玩意。", "难吃。"],
		"cleared_greasy": ["虽然不怕油，但清爽点正好接着大吃特吃！", "呼，总算把喉咙理顺了，再来！"],
		"cleared_fatigue": ["哦哦！味道又能尝出来了！继续吃！", "舌头复活了！把仓库都给我端上来！"],
		"got_greasy": ["啧，连我吃着都觉得太重口了！", "你是要把整罐猪油塞我嘴里吗！"],
		"got_fatigue": ["全都混在一块了！这是泔水吗！", "嚼得我舌头都僵了..."]
	},
	"eiki": {
		"high": ["嗯，很好。", "没什么可挑的。", "不错。"],
		"mid": ["一般般。", "还需要改进。", "差点意思。"],
		"low": ["不行。", "太差了。", "重做。"],
		"cleared_greasy": ["如净玻璃镜般透彻的味道。", "这份清爽，足以洗清之前的罪业了。"],
		"cleared_fatigue": ["明心见性，味觉又恢复了清明。", "善哉，如迷雾散去。"],
		"got_greasy": ["过于放纵油腻，这是罪过！", "判决：过度油腻之罪！"],
		"got_fatigue": ["味道太过繁杂导致麻木，需要反思！", "你的料理让人感官混沌了！"]
	},
	"remilia": {
		"high": ["还不错嘛。", "挺好的。", "可以。"],
		"mid": ["马马虎虎。", "一般。", "还行吧。"],
		"low": ["拿走。", "什么东西。", "太难吃了。"],
		"cleared_greasy": ["哼，不枉本小姐品尝，还算清爽优雅。", "正好解了刚刚那粗劣的腻味。咲夜，记下这个味道。"],
		"cleared_fatigue": ["贵族可不喜欢麻木的口感，现在好多了。", "不错的提神物。"],
		"got_greasy": ["你想用油脂谋杀吸血鬼吗？！拿走拿走！", "这种油腻腻的庶民食物别端上来！"],
		"got_fatigue": ["咲夜！我的舌头为什么没感觉了！", "毫无层次的堆砌，简直是在折磨我的高雅味觉。"]
	},
	"tenshi": {
		"high": ["好吃！", "不错嘛！", "再来！"],
		"mid": ["就那样吧。", "无聊。", "随便。"],
		"low": ["难吃！", "什么破玩意！", "没劲。"],
		"cleared_greasy": ["本天人才不带哪怕一点泥淖的味道！", "算你有眼光，解了这凡尘的油俗！"],
		"cleared_fatigue": ["总算有点像样的刺激了！", "对，这就是我追求的变化！"],
		"got_greasy": ["好油腻！下界人就只配吃油渣吗！", "别把这恶心的油块塞给我！"],
		"got_fatigue": ["太无聊了！吃起来跟嚼木头一样！", "我要拔剑了！这什么枯燥乏味的东西！"]
	},
	"iku": {
		"high": ["嗯，很香。", "口感不错。"],
		"mid": ["有点淡。", "还好。"],
		"low": ["不太舒服。", "不行啊这个。"]
	},
	"miko": {
		"high": ["很好。", "做得不错。"],
		"mid": ["一般。", "还可以吧。"],
		"low": ["不知道在做什么。", "乱七八糟的。"]
	},
	"kokoro": {
		"high": ["好吃。", "喜欢。"],
		"mid": ["还行。", "没什么感觉。"],
		"low": ["难吃。", "不喜欢。"]
	},
	"sakuya": {
		"high": ["做得很好。", "火候到位。"],
		"mid": ["有点粗糙。", "还差一点。"],
		"low": ["不行。", "太粗糙了。"]
	},
	"marisa": {
		"high": ["好吃！带劲！", "不错啊！"],
		"mid": ["还行吧。", "有点干。"],
		"low": ["一点味都没有。", "不行不行。"]
	},
	"reimu": {
		"high": ["真香！", "好吃！"],
		"mid": ["凑合吧。", "有点淡。"],
		"low": ["什么啊这个。", "难吃死了。"]
	},
	"patchouli": {
		"high": ["配比很精准，好吃。", "不错的搭配。"],
		"mid": ["太保守了。", "一般。"],
		"low": ["失败了。", "不想吃。"]
	}
}

func _ready():
	pivot_offset = size / 2
	emotion_label.text = ""
	
	bubble = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	style.border_width_left = 2; style.border_width_right = 2; style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.2, 0.2, 0.3, 1.0)
	style.corner_radius_top_left = 12; style.corner_radius_top_right = 12; style.corner_radius_bottom_right = 16; style.corner_radius_bottom_left = 0
	style.content_margin_left = 12; style.content_margin_right = 12; style.content_margin_top = 8; style.content_margin_bottom = 8
	bubble.add_theme_stylebox_override("panel", style)
	
	bubble_label = Label.new()
	bubble_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.15))
	bubble_label.add_theme_font_size_override("font_size", 16)
	bubble.add_child(bubble_label)
	
	add_child(bubble)
	bubble.position = Vector2(80, -60)
	bubble.hide()

var _last_env: Dictionary = {}

func setup(judge_id: String) -> void:
	_judge_id = judge_id.to_lower()
	if judge_id and ArtDatabase:
		var portrait = ArtDatabase.get_judge_portrait(judge_id)
		if portrait:
			texture_rect.texture = portrait
		else:
			push_warning("评委头像未找到: %s" % judge_id)

func react_to_impact(flavor: float, current_env: Dictionary = {}):
	# 计算环境词条变化
	var env_reaction = ""
	var greasy = current_env.get("greasy", 0)
	var fatigue = current_env.get("taste_fatigue", 0)
	var last_greasy = _last_env.get("greasy", 0)
	var last_fatigue = _last_env.get("taste_fatigue", 0)
	
	if greasy < last_greasy:
		env_reaction = "cleared_greasy"
	elif fatigue < last_fatigue:
		env_reaction = "cleared_fatigue"
	elif greasy > last_greasy and greasy >= 2:
		env_reaction = "got_greasy"
	elif fatigue > last_fatigue and fatigue >= 2:
		env_reaction = "got_fatigue"
		
	_last_env = current_env.duplicate()

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
		if env_reaction == "cleared_greasy" or env_reaction == "cleared_fatigue":
			show_emotion("✨")
		elif env_reaction == "got_greasy":
			show_emotion("🤢")
		elif env_reaction == "got_fatigue":
			show_emotion("😴")
		else:
			show_emotion("🙂")
		
	# 台词气泡（环境反应必然触发，普通味道35%触发）
	var prob = 1.0 if env_reaction != "" else 0.35
	if randf() < prob:
		show_dialogue(flavor, env_reaction)

func show_dialogue(flavor: float, env_reaction: String = "") -> void:
	var lines = []
	if env_reaction != "" and _dialogues.has(_judge_id) and _dialogues[_judge_id].has(env_reaction):
		lines = _dialogues[_judge_id][env_reaction]
	elif env_reaction != "":
		match env_reaction:
			"cleared_greasy": lines = ["呼，没那么油腻了。", "爽口多了！", "正好解腻。"]
			"cleared_fatigue": lines = ["舌头恢复知觉了。", "清新的味道！", "醒神了。"]
			"got_greasy": lines = ["好油腻啊...", "这太重口了吧。", "喉咙被糊住了..."]
			"got_fatigue": lines = ["吃不出味道了。", "嘴巴有点麻木。", "味道都混杂在一起了。"]
			_: lines = ["..."]
	else:
		var category = "mid"
		if flavor > 40.0: category = "high"
		elif flavor < 10.0: category = "low"
		
		if _dialogues.has(_judge_id) and _dialogues[_judge_id].has(category):
			lines = _dialogues[_judge_id][category]
		else:
			lines = ["嗯，有意思。", "味道很特别。", "厨师下功夫了。"]
			if flavor > 40.0: lines = ["美味！", "太棒了！", "手艺精湛！"]
			elif flavor < 10.0: lines = ["还需要努力。", "这也能叫菜？"]
		
	bubble_label.text = lines[randi() % lines.size()]
	bubble.show()
	bubble.modulate.a = 0.0
	
	if _bubble_tween and _bubble_tween.is_valid():
		_bubble_tween.kill()
	_bubble_tween = create_tween()
	_bubble_tween.tween_property(bubble, "modulate:a", 1.0, 0.2)
	_bubble_tween.tween_interval(2.5)
	_bubble_tween.tween_property(bubble, "modulate:a", 0.0, 0.3)
	_bubble_tween.tween_callback(bubble.hide)

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
