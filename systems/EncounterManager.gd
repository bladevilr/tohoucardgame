extends Node

## 三选一事件系统 — 东方料理对决
## 每个事件节点生成3个选项(A/B/C)，按日程阶段分类
## 事件类型：资源赌博(Risk/Reward)、强制改造(Mutation)、战前情报(Scouting)
## 融入东方Project世界观，每个事件都有角色和故事

# === PvE 对手模板 ===
var _pve_opponents: Array = []# === 事件池：按行动阶段分类 ===
var _event_pools := {
	"morning_event": [],   # 清晨奇遇 — 偏经济/资源
	"market_rumor": [],    # 早市传闻 — 偏情报/规则变化
	"afternoon_tea": [],   # 下午茶歇 — 偏战力强化
	"dusk_market": [],     # 黄昏暗盘 — 高风险高回报
}

func _ready():
	_init_pve_opponents()
	_init_event_pools()

# ============================================================
#  PvE 对手
# ============================================================
func _init_pve_opponents():
	_pve_opponents = [
		# Day 1-3: 简单对手
		{"id": "fairy_mob", "name": "饥饿的妖精群", "min_day": 1, "max_day": 3,
		 "difficulty": 1, "reward_gold": 4,
		 "desc": "一群嗅到香味的小妖精围了过来，用你的料理打发她们吧。",
		 "flavor": "「好香好香！给我们吃一点嘛～」"},
		{"id": "rumia", "name": "露米娅的宵夜", "min_day": 1, "max_day": 4,
		 "difficulty": 1, "reward_gold": 5,
		 "desc": "黑暗中传来咕噜声……是那个总说「是那样的吗」的暗之妖怪。",
		 "flavor": "「那个……有没有不用看就能吃的料理？」"},
		{"id": "cirno_challenge", "name": "琪露诺的挑战", "min_day": 1, "max_day": 5,
		 "difficulty": 2, "reward_gold": 5,
		 "desc": "最强的妖精自信满满地摆出了她的冰冻料理阵容。",
		 "flavor": "「⑨号选手登场！看我的刨冰连击！」"},
		# Day 3-6: 中等对手
		{"id": "keine_exam", "name": "慧音的料理考试", "min_day": 3, "max_day": 7,
		 "difficulty": 2, "reward_gold": 6,
		 "desc": "寺子屋的老师决定用料理来考验你的基本功。",
		 "flavor": "「料理和历史一样，基础不牢地动山摇。来，展示你的实力。」"},
		{"id": "mokou_yakitori", "name": "妹红的烤鸡摊", "min_day": 3, "max_day": 8,
		 "difficulty": 2, "reward_gold": 7,
		 "desc": "不死鸟的炭火烤鸡，传说中永远不会烤焦的完美火候。",
		 "flavor": "「活了一千多年，烤鸡这种事闭着眼都会了。」"},
		# Day 5-10: 困难对手
		{"id": "eirin_medicine", "name": "永琳的药膳试炼", "min_day": 5, "max_day": 12,
		 "difficulty": 3, "reward_gold": 8,
		 "desc": "月之贤者的药膳料理，每一道都蕴含着千年的智慧。",
		 "flavor": "「药食同源——让我看看你是否理解这个道理。」"},
		{"id": "yuyuko_feast", "name": "幽幽子的满汉全席", "min_day": 6, "max_day": 15,
		 "difficulty": 3, "reward_gold": 10,
		 "desc": "亡灵公主的食量是无底洞，你的料理能填满她吗？",
		 "flavor": "「妖梦～这个人说要请我吃饭呢～再来十份！」"},
		{"id": "remilia_dinner", "name": "蕾米的晚宴", "min_day": 7, "max_day": 15,
		 "difficulty": 3, "reward_gold": 10,
		 "desc": "红魔馆大小姐的私人晚宴邀请，菜品必须符合贵族标准。",
		 "flavor": "「咲夜，把那个不够精致的撤下去。」"},
	]

# ============================================================
#  三选一事件池
# ============================================================
func _init_event_pools():
	# ========== 清晨奇遇 (偏经济/资源) ==========
	_event_pools.morning_event = [
		_make_event("shrine_donation", "神社的赛钱箱",
			"路过博丽神社时，灵梦正在打扫落叶。她看了你一眼，指了指赛钱箱。",
			"「虽然没什么人来参拜……但投了钱的人运气都不错哦。」",
			[
				_choice("A", "投入5金币祈福", "lose_gold_5_gain_random_ingredient_gold",
					"虔诚地投入赛钱。灵梦露出了难得的笑容。"),
				_choice("B", "帮忙打扫换取报酬", "gain_gold_3",
					"卷起袖子帮灵梦扫落叶，获得3金币报酬。"),
				_choice("C", "偷看赛钱箱", "gain_gold_2_lose_prestige_1",
					"趁灵梦不注意瞄了一眼……被发现了。声望-1但摸到了2金币。"),
			]),
		_make_event("kourindou_sale", "香霖堂的跳蚤市场",
			"森近霖之助难得地在门口摆出了「大甩卖」的牌子。",
			"「这些都是外界来的好东西……虽然我也不太清楚怎么用。」",
			[
				_choice("A", "花3金币淘宝", "lose_gold_3_gain_random_technique",
					"在杂物堆里翻到了一本料理技法秘籍！"),
				_choice("B", "用一道菜换购", "lose_random_dish_gain_gold_6",
					"霖之助对你的料理很感兴趣，愿意高价收购。"),
				_choice("C", "只是看看", "gain_gold_1",
					"逛了一圈什么都没买，但在地上捡到了1金币。"),
			]),
		_make_event("morning_mist", "迷途竹林",
			"清晨的迷途竹林雾气弥漫，你在竹林深处发现了一个分岔路。",
			"远处传来永远亭的铃声，另一边似乎有篝火的光芒……",
			[
				_choice("A", "走向永远亭", "gain_random_ingredient_silver",
					"永琳送了你一份珍贵的药材作为迷路的补偿。"),
				_choice("B", "走向篝火", "gain_gold_4_gain_char_aroma",
					"是妹红在烤竹笋！她分了你一些，还教了你控火技巧。获得4金币。"),
				_choice("C", "原路返回", "gain_gold_2",
					"安全第一。虽然没什么收获，但至少没迷路。获得2金币。"),
			]),
		_make_event("fairy_market", "妖精的早市",
			"三月精在湖边摆了个小摊，卖的东西……看起来很可疑。",
			"「便宜卖啦便宜卖啦！绝对不是从红魔馆偷来的！」",
			[
				_choice("A", "花2金币买「神秘包裹」", "lose_gold_2_random_reward",
					"打开一看——Loss: 50%概率是垃圾，50%概率是稀有食材！"),
				_choice("B", "举报给咲夜", "gain_gold_3_next_shop_discount",
					"咲夜感谢你的情报，给了你3金币和下次商店折扣。"),
				_choice("C", "和她们聊天", "gain_gold_1_reveal_judges",
					"妖精们不小心透露了今天评委的喜好。获得1金币+评委情报。"),
			]),
		_make_event("river_fishing", "三途河垂钓",
			"小町正在三途河边偷懒钓鱼，看到你走过来招了招手。",
			"「要不要试试？这河里的鱼可不一般哦～映姬大人不在就是好。」",
			[
				_choice("A", "花3金币租鱼竿", "lose_gold_3_gain_ingredient_diamond",
					"钓上了一条散发着灵光的鱼！传说级食材！"),
				_choice("B", "帮小町划船", "gain_gold_5",
					"帮她送了几个灵魂过河，赚了5金币的外快。"),
				_choice("C", "和小町聊八卦", "gain_random_event_info",
					"小町告诉你今天会发生什么事件，让你提前做好准备。"),
			]),
	]

	# ========== 早市传闻 (偏情报/规则变化) ==========
	_event_pools.market_rumor = [
		_make_event("aya_newspaper", "文文的新闻速报",
			"射命丸文挥舞着刚印好的报纸冲了过来。",
			"「独家头条！今晚的料理对决有大新闻！要不要先睹为快？」",
			[
				_choice("A", "花2金币买报纸", "lose_gold_2_reveal_opponent",
					"报纸上详细刊登了今晚对手的料理阵容！知己知彼。"),
				_choice("B", "提供料理换情报", "lose_random_ingredient_gain_intel",
					"文拿走了你一份食材，但告诉你了对手的弱点菜系。"),
				_choice("C", "拒绝，自己准备", "gain_gold_2_gain_technique_buff",
					"不需要情报，实力说话。专注备战，技法临时+10%。"),
			]),
		_make_event("keine_history", "慧音的历史课",
			"慧音在寺子屋讲述着幻想乡料理大赛的历史。",
			"「历史总是惊人地相似……了解过去，才能把握未来。」",
			[
				_choice("A", "认真听课", "gain_all_stats_2",
					"慧音的讲解让你对料理有了更深的理解。全菜品属性+2。"),
				_choice("B", "翻阅古籍", "gain_random_technique",
					"在古籍中发现了一种失传的料理技法！"),
				_choice("C", "逃课去玩", "gain_gold_3",
					"溜出教室在人里闲逛，捡到了3金币。"),
			]),
		_make_event("nitori_gadget", "河城荷取的新发明",
			"河童工程师兴奋地展示着她的最新厨房发明。",
			"「这个自动切菜机只炸了三次！成功率已经很高了！」",
			[
				_choice("A", "花4金币购买", "lose_gold_4_gain_random_tool",
					"虽然看起来不太靠谱，但确实是一件好厨具！"),
				_choice("B", "帮忙测试", "random_tool_buff_or_debuff",
					"50%概率获得强力厨具buff，50%概率厨具全部CD+1秒。"),
				_choice("C", "礼貌拒绝", "gain_gold_1",
					"荷取有点失望，但还是给了你1金币作为来访礼。"),
			]),
		_make_event("kosuzu_book", "小铃的禁书",
			"铃奈庵的小铃偷偷拿出了一本妖怪写的料理书。",
			"「这本书……好像会动。但里面的食谱看起来很厉害的样子！」",
			[
				_choice("A", "抄录食谱", "gain_random_dish_upgrade",
					"成功抄录了一份高级食谱，随机一道菜品升星！"),
				_choice("B", "买下整本书", "lose_gold_5_gain_2_techniques",
					"花5金币买下禁书，获得2个随机技法！"),
				_choice("C", "提醒小铃危险", "gain_prestige_1",
					"小铃感激地收起了书。你的声望+1。"),
			]),
	]

	# ========== 下午茶歇 (偏战力强化) ==========
	_event_pools.afternoon_tea = [
		_make_event("sakuya_training", "咲夜的刀工特训",
			"完美而优雅的女仆正在厨房练习刀工，银色的刀光令人目眩。",
			"「想学吗？不过我的训练可不轻松。」",
			[
				_choice("A", "接受特训", "all_dish_technique_plus_3",
					"经过咲夜的魔鬼训练，你的刀工突飞猛进。全菜品技法+3。"),
				_choice("B", "请教时间管理", "all_dish_cd_minus_05",
					"咲夜教你如何在有限时间内最大化效率。全菜品CD-0.5秒。"),
				_choice("C", "一起喝茶", "gain_gold_2_gain_presentation_3",
					"优雅的下午茶时光。获得2金币，全菜品卖相+3。"),
			]),
		_make_event("alice_plating", "爱丽丝的摆盘课",
			"人偶使正在用她的人偶们演示精致的摆盘技巧。",
			"「料理不只是味道，视觉也是重要的一环。来，我教你。」",
			[
				_choice("A", "学习摆盘", "all_dish_presentation_plus_5",
					"在爱丽丝的指导下，你的摆盘水平大幅提升。全菜品卖相+5。"),
				_choice("B", "借用人偶帮忙", "gain_plating_keyword_3",
					"爱丽丝的人偶在对决中帮你摆盘。获得3层「摆盘」关键词。"),
				_choice("C", "交换料理心得", "gain_random_ingredient_gold",
					"愉快的交流后，爱丽丝送了你一份珍贵的食材。"),
			]),
		_make_event("patchouli_research", "帕秋莉的元素研究",
			"大图书馆的魔女正在研究五行与料理的关系。",
			"「火生土，土生金……料理中的五行相生，你理解吗？」",
			[
				_choice("A", "参与研究", "gain_synergy_bonus",
					"帕秋莉的研究让你的料理羁绊效果增强20%。"),
				_choice("B", "借阅魔导书", "gain_2_random_ingredients",
					"在书中找到了两种珍贵食材的线索。获得2个随机食材。"),
				_choice("C", "帮忙整理书架", "gain_gold_4",
					"帕秋莉付了你4金币的整理费。"),
			]),
		_make_event("suika_drinking", "萃香的酒宴",
			"鬼族的小萃香正在举办即兴酒宴，空气中弥漫着酒香。",
			"「来嘛来嘛！喝了我的酒，保证你今晚超常发挥！」",
			[
				_choice("A", "痛饮三杯", "gain_flavor_8_lose_presentation_3",
					"酒劲上头！全菜品风味+8，但卖相-3（手抖了）。"),
				_choice("B", "小酌一杯", "gain_flavor_4_gain_aroma_4",
					"适量饮酒，灵感涌现。全菜品风味+4，香气+4。"),
				_choice("C", "以茶代酒", "gain_aroma_5",
					"用茶敬酒，萃香虽然不满但也接受了。全菜品香气+5。"),
			]),
	]

	# ========== 黄昏暗盘 (高风险高回报) ==========
	_event_pools.dusk_market = [
		_make_event("seija_gamble", "正邪的颠倒赌局",
			"天邪鬼在暗巷里摆了个赌摊，笑容意味深长。",
			"「来赌一把吧？我保证……绝对公平。嘻嘻。」",
			[
				_choice("A", "全押！", "gamble_all_in",
					"50%概率金币翻倍，50%概率失去一半金币。"),
				_choice("B", "小赌怡情", "gamble_small",
					"花3金币赌博。70%赢6金币，30%什么都没有。"),
				_choice("C", "举报赌摊", "gain_prestige_1_gain_gold_2",
					"向慧音举报了非法赌摊。声望+1，获得2金币奖励。"),
			]),
		_make_event("medicine_poison", "梅蒂欣的毒药铺",
			"人偶妖怪在月光下摆出了各种颜色的小瓶子。",
			"「这些都是铃兰的精华哦～用好了是良药，用不好嘛……」",
			[
				_choice("A", "购买「极致调味料」", "lose_gold_3_mutate_dish",
					"选择一道菜，风味永久×2，但附加「剧毒」标签（每次激活给对手加分）。"),
				_choice("B", "购买「解毒剂」", "lose_gold_2_clear_all_debuffs",
					"清除你所有菜品上的负面标签和环境debuff。"),
				_choice("C", "远离毒药", "gain_gold_1",
					"明智的选择。在离开时捡到了1金币。"),
			]),
		_make_event("yukari_gap", "紫的隙间商店",
			"空间裂缝中伸出一只戴着手套的手，手上托着一个礼盒。",
			"「呵呵……想要吗？代价嘛，就看你愿意付出什么了。」",
			[
				_choice("A", "献上3点声望", "lose_prestige_3_gain_diamond_ingredient",
					"紫满意地收下了你的声望，给了你一份传说级食材。"),
				_choice("B", "献上一道菜品", "lose_best_dish_gain_2_gold_dishes",
					"失去你最强的菜品，但获得2道金级菜品作为补偿。"),
				_choice("C", "拒绝交易", "gain_gold_2",
					"紫笑了笑，隙间关闭了。地上留下了2金币。"),
			]),
		_make_event("mamizou_disguise", "猯藏的变化术",
			"化狸在夜色中现出原形，手里拿着一片神奇的树叶。",
			"「用这片叶子，可以让你的料理变成完全不同的东西哦～」",
			[
				_choice("A", "变化最弱的菜品", "transform_weakest_to_random_gold",
					"你最弱的菜品变成了一道随机金级菜品！"),
				_choice("B", "变化一份食材", "transform_ingredient_to_diamond",
					"一份普通食材变成了传说级食材！"),
				_choice("C", "学习变化术", "gain_gold_3_gain_random_tag",
					"猯藏教你给一道菜品附加一个随机有利标签。获得3金币。"),
			]),
		_make_event("hecatia_otherworld", "赫卡提亚的异世界料理",
			"地狱女神带来了三个不同世界的料理样本。",
			"「月之都的、地狱的、还有外界的——选一个尝尝？」",
			[
				_choice("A", "月之都料理", "gain_presentation_10_aroma_5",
					"精致到极点的月都料理。全菜品卖相+10，香气+5。"),
				_choice("B", "地狱料理", "gain_flavor_12_lose_presentation_5",
					"灼热的地狱风味！全菜品风味+12，但卖相-5。"),
				_choice("C", "外界料理", "gain_all_stats_4",
					"均衡的外界现代料理。全菜品全属性+4。"),
			]),
	]

# ============================================================
#  数据构造辅助
# ============================================================
func _make_event(id: String, name: String, desc: String, flavor: String, choices: Array) -> Dictionary:
	return {
		"id": id, "name": name, "description": desc,
		"flavor_text": flavor, "choices": choices, "type": "event",
	}

func _choice(label: String, text: String, effect_id: String, result_text: String) -> Dictionary:
	return {
		"label": label, "text": text,
		"effect_id": effect_id, "result_text": result_text,
	}

# ============================================================
#  公共 API
# ============================================================
func generate_encounter_for_action(action_id: String, day: int, action_num: int) -> Dictionary:
	"""Generate a three-choice event for the given action slot."""
	var pool = _event_pools.get(action_id, [])
	if pool.is_empty():
		pool = _event_pools.get("morning_event", [])
	if pool.is_empty():
		return {"id": "empty", "name": "无事发生", "choices": [], "type": "event"}
	pool.shuffle()
	var event = pool[0].duplicate(true)
	event["day"] = day
	event["action"] = action_num
	return event

func generate_pve_opponent(day: int) -> Dictionary:
	"""Generate a PvE opponent appropriate for the current day."""
	var available: Array = []
	for opp in _pve_opponents:
		if day >= opp.get("min_day", 1) and day <= opp.get("max_day", 99):
			available.append(opp)
	if available.is_empty():
		available = _pve_opponents
	available.shuffle()
	var opponent = available[0].duplicate(true)
	opponent["type"] = "pve_battle"
	opponent["reward_gold"] = int(opponent.get("reward_gold", 3) + day * 0.5)
	return opponent

func generate_pve_choices(day: int) -> Array:
	"""Return 3 PvE opponents, one per difficulty tier (easy/medium/hard)."""
	var by_diff: Dictionary = {1: [], 2: [], 3: []}
	var all_by_diff: Dictionary = {1: [], 2: [], 3: []}
	for opp in _pve_opponents:
		var d: int = clampi(int(opp.get("difficulty", 1)), 1, 3)
		all_by_diff[d].append(opp)
		if day >= opp.get("min_day", 1) and day <= opp.get("max_day", 99):
			by_diff[d].append(opp)
	# Fallback: if no day-appropriate opponent for a tier, use any from that tier
	for diff in [1, 2, 3]:
		if by_diff[diff].is_empty():
			by_diff[diff] = all_by_diff[diff] if not all_by_diff[diff].is_empty() else _pve_opponents
	var result: Array = []
	for diff in [1, 2, 3]:
		var pool: Array = by_diff[diff].duplicate()
		pool.shuffle()
		var pick: Dictionary = pool[0].duplicate(true)
		pick["type"] = "pve_battle"
		pick["reward_gold"] = int(pick.get("reward_gold", 3) + day * 0.5)
		result.append(pick)
	return result

func resolve_encounter(player: PlayerState, encounter: Dictionary, choice_idx: int = 0) -> Dictionary:
	"""Resolve a three-choice event. choice_idx is 0/1/2 for A/B/C."""
	var result := {"success": true, "rewards": [], "text": ""}
	var choices = encounter.get("choices", [])
	if choices.is_empty():
		return result

	choice_idx = clampi(choice_idx, 0, choices.size() - 1)
	var chosen = choices[choice_idx]
	var effect_id = chosen.get("effect_id", "")
	result["text"] = chosen.get("result_text", "")
	result["choice_label"] = chosen.get("label", "")
	result["choice_text"] = chosen.get("text", "")

	_execute_effect(player, effect_id, result)

	SignalBus.encounter_completed.emit(result)
	return result

func resolve_pve(player: PlayerState, pve_data: Dictionary, won: bool) -> Dictionary:
	"""Resolve PvE battle result."""
	var result := {"success": won, "rewards": []}
	if won:
		var gold = pve_data.get("reward_gold", 3)
		player.add_gold(gold)
		result["gold_gained"] = gold
		result["text"] = "胜利！获得%d金币。" % gold
	else:
		var loss = mini(2, player.gold)
		if loss > 0:
			player.gold -= loss
		result["gold_lost"] = loss
		result["text"] = "惜败……损失了%d金币，但不扣声望。" % loss
	SignalBus.encounter_completed.emit(result)
	return result

# ============================================================
#  效果执行引擎
# ============================================================
func _execute_effect(player: PlayerState, effect_id: String, result: Dictionary):
	match effect_id:
		# === 金币操作 ===
		"gain_gold_1":
			player.add_gold(1); result["gold_gained"] = 1
		"gain_gold_2":
			player.add_gold(2); result["gold_gained"] = 2
		"gain_gold_3":
			player.add_gold(3); result["gold_gained"] = 3
		"gain_gold_4":
			player.add_gold(4); result["gold_gained"] = 4
		"gain_gold_5":
			player.add_gold(5); result["gold_gained"] = 5
		"gain_gold_2_lose_prestige_1":
			player.add_gold(2); player.prestige -= 1
			result["gold_gained"] = 2; result["prestige_lost"] = 1
		"gain_gold_2_gain_technique_buff":
			player.add_gold(2)
			_buff_all_dishes(player, "technique", 3)
			result["gold_gained"] = 2; result["buff"] = "technique+3"
		"gain_gold_3_next_shop_discount":
			player.add_gold(3)
			player.chef_skill_effect["_next_shop_discount"] = 0.5
			result["gold_gained"] = 3; result["shop_discount"] = true
		"gain_gold_1_reveal_judges":
			player.add_gold(1); result["gold_gained"] = 1
			result["revealed_judges"] = true
		"gain_gold_4_gain_char_aroma":
			player.add_gold(4)
			player.add_keyword("char_aroma", 2)
			result["gold_gained"] = 4; result["keyword_gained"] = "char_aroma"

		# === 金币消耗 + 奖励 ===
		"lose_gold_2_random_reward":
			if player.spend_gold(2):
				if randf() < 0.5:
					var ing = _random_ingredient_by_tier(1)
					result.rewards.append(ing)
					result["text"] += " 运气不错！获得了%s！" % ing.get("name", "食材")
				else:
					result["text"] += " 是个空盒子……"
			else:
				result["text"] = "金币不足。"
		"lose_gold_2_reveal_opponent":
			if player.spend_gold(2):
				result["revealed_opponent"] = true
			else:
				result["text"] = "金币不足。"
		"lose_gold_3_gain_random_technique":
			if player.spend_gold(3):
				var techs = TechniqueDatabase.get_all()
				techs.shuffle()
				if not techs.is_empty():
					var tech = techs[0].duplicate(true)
					tech["item_type"] = "technique"
					result.rewards.append(tech)
		"lose_gold_3_gain_ingredient_diamond":
			if player.spend_gold(3):
				result.rewards.append(_random_ingredient_by_tier(3))
		"lose_gold_4_gain_random_tool":
			if player.spend_gold(4):
				var tools = ToolDatabase.get_all()
				tools.shuffle()
				if not tools.is_empty():
					var tool = tools[0].duplicate(true)
					tool["item_type"] = "tool"
					result.rewards.append(tool)
		"lose_gold_5_gain_random_ingredient_gold":
			if player.spend_gold(5):
				result.rewards.append(_random_ingredient_by_tier(2))
				result.rewards.append(_random_ingredient_by_tier(2))
		"lose_gold_5_gain_2_techniques":
			if player.spend_gold(5):
				var techs = TechniqueDatabase.get_all()
				techs.shuffle()
				for i in range(mini(2, techs.size())):
					var t = techs[i].duplicate(true)
					t["item_type"] = "technique"
					result.rewards.append(t)
		"lose_gold_3_mutate_dish":
			if player.spend_gold(3):
				var items = player.get_board_items()
				if not items.is_empty():
					items.shuffle()
					var dish = items[0].item
					dish.base_stats["flavor"] = dish.base_stats.get("flavor", 0) * 2
					if "poison" not in dish.get("tags", []):
						dish.tags.append("poison")
					result["mutated_dish"] = dish.get("name", "???")

		# === 食材获取 ===
		"gain_random_ingredient_silver":
			result.rewards.append(_random_ingredient_by_tier(1))
		"gain_random_ingredient_gold":
			result.rewards.append(_random_ingredient_by_tier(2))
		"gain_2_random_ingredients":
			result.rewards.append(_random_ingredient_by_tier(1))
			result.rewards.append(_random_ingredient_by_tier(1))

		# === 技法获取 ===
		"gain_random_technique":
			var techs = TechniqueDatabase.get_all()
			techs.shuffle()
			if not techs.is_empty():
				var t = techs[0].duplicate(true)
				t["item_type"] = "technique"
				result.rewards.append(t)

		# === 菜品操作 ===
		"lose_random_dish_gain_gold_6":
			var items = player.get_board_items()
			if not items.is_empty():
				items.shuffle()
				var removed = player.remove_item(items[0].slot_idx)
				player.add_gold(6)
				result["gold_gained"] = 6
				result["lost_dish"] = removed.get("name", "???") if removed else ""
		"lose_best_dish_gain_2_gold_dishes":
			var items = player.get_board_items()
			if not items.is_empty():
				items.sort_custom(func(a, b): return _dish_power(a.item) > _dish_power(b.item))
				player.remove_item(items[0].slot_idx)
				result["lost_dish"] = items[0].item.get("name", "???")
				var dishes = DishDatabase.get_dishes()
				dishes.shuffle()
				var count = 0
				for d in dishes:
					if d.get("tier", 0) >= 2 and count < 2:
						result.rewards.append(d.duplicate(true))
						count += 1
		"gain_random_dish_upgrade":
			var items = player.get_board_items()
			if not items.is_empty():
				items.shuffle()
				var dish = items[0].item
				var star = dish.get("star_level", 1)
				if star < 3:
					dish["star_level"] = star + 1
					var mult = GameConfig.STAR2_MULTIPLIER if star + 1 == 2 else GameConfig.STAR3_MULTIPLIER
					for attr in dish.get("base_stats", {}):
						dish.base_stats[attr] = float(dish.base_stats[attr]) * mult
					result["upgraded_dish"] = dish.get("name", "???")
		"transform_weakest_to_random_gold":
			var items = player.get_board_items()
			if not items.is_empty():
				items.sort_custom(func(a, b): return _dish_power(a.item) < _dish_power(b.item))
				var slot = items[0].slot_idx
				player.remove_item(slot)
				var gold_dishes = DishDatabase.get_dishes().filter(func(d): return d.get("tier", 0) >= 2)
				gold_dishes.shuffle()
				if not gold_dishes.is_empty():
					var new_dish = gold_dishes[0].duplicate(true)
					result.rewards.append(new_dish)
					result["transformed"] = true
		"transform_ingredient_to_diamond":
			var bp_ingredients: Array = []
			for i in range(player.backpack.size()):
				if player.backpack[i].get("item_type", "") == "ingredient":
					bp_ingredients.append(i)
			if not bp_ingredients.is_empty():
				bp_ingredients.shuffle()
				player.backpack.remove_at(bp_ingredients[0])
				result.rewards.append(_random_ingredient_by_tier(3))

		# === 全体菜品 Buff ===
		"all_dish_technique_plus_3":
			_buff_all_dishes(player, "technique", 3)
		"all_dish_cd_minus_05":
			for entry in player.get_board_items():
				entry.item["cooldown"] = maxf(1.0, float(entry.item.get("cooldown", 3.0)) - 0.5)
		"all_dish_presentation_plus_5":
			_buff_all_dishes(player, "presentation", 5)
		"gain_all_stats_2":
			for attr in ["flavor", "presentation", "technique", "aroma"]:
				_buff_all_dishes(player, attr, 2)
		"gain_all_stats_4":
			for attr in ["flavor", "presentation", "technique", "aroma"]:
				_buff_all_dishes(player, attr, 4)
		"gain_flavor_4_gain_aroma_4":
			_buff_all_dishes(player, "flavor", 4)
			_buff_all_dishes(player, "aroma", 4)
		"gain_flavor_8_lose_presentation_3":
			_buff_all_dishes(player, "flavor", 8)
			_buff_all_dishes(player, "presentation", -3)
		"gain_aroma_5":
			_buff_all_dishes(player, "aroma", 5)
		"gain_presentation_10_aroma_5":
			_buff_all_dishes(player, "presentation", 10)
			_buff_all_dishes(player, "aroma", 5)
		"gain_flavor_12_lose_presentation_5":
			_buff_all_dishes(player, "flavor", 12)
			_buff_all_dishes(player, "presentation", -5)
		"gain_gold_2_gain_presentation_3":
			player.add_gold(2)
			_buff_all_dishes(player, "presentation", 3)
			result["gold_gained"] = 2

		# === 关键词 ===
		"gain_plating_keyword_3":
			player.add_keyword("plating", 3)
			result["keyword_gained"] = "plating"

		# === 声望 ===
		"gain_prestige_1":
			player.prestige += 1; result["prestige_gained"] = 1
		"gain_prestige_1_gain_gold_2":
			player.prestige += 1; player.add_gold(2)
			result["prestige_gained"] = 1; result["gold_gained"] = 2
		"lose_prestige_3_gain_diamond_ingredient":
			player.prestige = maxi(1, player.prestige - 3)
			result.rewards.append(_random_ingredient_by_tier(3))
			result["prestige_lost"] = 3

		# === 赌博 ===
		"gamble_all_in":
			if randf() < 0.5:
				var bonus = player.gold
				player.add_gold(bonus)
				result["gold_gained"] = bonus
				result["text"] = "大赢！金币翻倍！获得%d金币！" % bonus
			else:
				var loss = int(player.gold / 2)
				player.gold -= loss
				result["gold_lost"] = loss
				result["text"] = "惨败……失去了%d金币。" % loss
		"gamble_small":
			if player.spend_gold(3):
				if randf() < 0.7:
					player.add_gold(6)
					result["gold_gained"] = 6
					result["text"] = "小赌怡情，赢了6金币！"
				else:
					result["text"] = "手气不好，3金币打了水漂。"

		# === 羁绊 ===
		"gain_synergy_bonus":
			player.chef_skill_effect["_synergy_bonus"] = 0.20
			result["synergy_bonus"] = true

		# === 杂项 ===
		"random_tool_buff_or_debuff":
			if randf() < 0.5:
				_buff_all_dishes(player, "technique", 5)
				result["text"] = "发明成功！全菜品技法+5！"
			else:
				for entry in player.get_board_items():
					entry.item["cooldown"] = float(entry.item.get("cooldown", 3.0)) + 1.0
				result["text"] = "发明爆炸了……全菜品CD+1秒。"
		"lose_gold_2_clear_all_debuffs":
			if player.spend_gold(2):
				for entry in player.get_board_items():
					var tags = entry.item.get("tags", [])
					tags.erase("poison")
					tags.erase("cursed")
					tags.erase("burnt")
		"lose_random_ingredient_gain_intel":
			var bp_ingredients: Array = []
			for i in range(player.backpack.size()):
				if player.backpack[i].get("item_type", "") == "ingredient":
					bp_ingredients.append(i)
			if not bp_ingredients.is_empty():
				bp_ingredients.shuffle()
				player.backpack.remove_at(bp_ingredients[0])
			result["revealed_opponent_cuisine"] = true
		"gain_random_event_info":
			result["event_preview"] = true
		"gain_gold_3_gain_random_tag":
			player.add_gold(3)
			var good_tags = ["mastered", "rich", "umami_tag", "fermented"]
			var items = player.get_board_items()
			if not items.is_empty():
				items.shuffle()
				var tag = good_tags[randi() % good_tags.size()]
				if tag not in items[0].item.get("tags", []):
					items[0].item.tags.append(tag)
				result["added_tag"] = tag
			result["gold_gained"] = 3

# ============================================================
#  内部辅助
# ============================================================
func _random_ingredient_by_tier(tier: int) -> Dictionary:
	var pool = IngredientDatabase.get_by_tier(tier)
	if pool.is_empty():
		pool = IngredientDatabase.get_all()
	pool.shuffle()
	if pool.is_empty():
		return {"id": "unknown", "name": "神秘食材", "item_type": "ingredient"}
	return pool[0].duplicate(true)

func _buff_all_dishes(player: PlayerState, attr: String, amount: int):
	for entry in player.get_board_items():
		var stats = entry.item.get("base_stats", {})
		stats[attr] = maxf(0, float(stats.get(attr, 0)) + amount)

func _dish_power(dish: Dictionary) -> float:
	var stats = dish.get("base_stats", {})
	return float(stats.get("flavor", 0)) + float(stats.get("presentation", 0)) + float(stats.get("technique", 0)) + float(stats.get("aroma", 0))

# Legacy compatibility
func generate_encounter(day: int) -> Dictionary:
	return generate_encounter_for_action("morning_event", day, 1)
