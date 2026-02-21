extends Node
class_name UIHelper

## UIHelper �?静态翻译工具类
## 提供所有UI显示用的中文翻译函数，避免在各个UI文件中重复编写翻译逻辑�?## 使用方式：UIHelper.函数�?) （通过class_name或直接preload�?
# ============================================================
# 标签翻译
# ============================================================

static func get_tag_chinese(tag: String) -> String:
	var map = {
		# 菜系
		"chinese": "中华", "french": "法餐", "japanese": "和食",
		"wild": "野味", "molecular": "分子", "dessert": "甜品",
		"fusion": "融合", "ingredient": "食材",
		# 口味
		"spicy": "�?, "sweet": "�?, "sour": "�?, "salty": "�?,
		"umami": "�?, "bitter": "�?,
		# 食材类型
		"meat": "肉类", "seafood": "海鲜", "vegetable": "蔬菜",
		"poultry": "禽类", "pork": "猪肉", "beef": "牛肉",
		"egg": "蛋类", "tofu": "豆腐", "mushroom": "菌菇",
		"fruit": "水果", "dairy": "乳制�?, "chocolate": "巧克�?,
		"flour": "面粉", "rice": "�?, "noodle": "�?,
		"truffle": "松露", "foie_gras": "鹅肝",
		# 烹饪方式
		"roasted": "烤制", "grilled": "炙烤", "fried": "油炸",
		"steamed": "蒸制", "stewed": "炖煮", "raw": "生食",
		"stir_fried": "炒制", "braised": "红烧", "smoked": "烟熏",
		"boiled": "水煮", "baked": "烘焙", "deep_fried": "酥炸",
		# 菜品类型
		"soup": "�?, "staple": "主食", "roast": "�?,
		"stew": "�?, "salad": "沙拉", "appetizer": "前菜",
		"main": "主菜", "side": "配菜",
		# 特�?		"iconic": "招牌", "classic": "经典", "modern": "现代",
		"traditional": "传统", "innovative": "创新",
		"rich": "浓郁", "light": "清淡", "refreshing": "清爽",
		"hearty": "丰盛", "delicate": "精致", "rustic": "质朴",
		"elegant": "优雅", "bold": "浓烈", "subtle": "淡雅",
		"aromatic": "芬芳", "crispy": "酥脆", "tender": "嫩滑",
		"creamy": "奶香", "smoky": "烟熏风味", "tangy": "酸甜",
		# 大小
		"small": "小型", "medium": "中型", "large": "大型",
		# 配料
		"scallion": "�?, "garlic": "�?, "ginger": "�?,
		"vinegar": "�?, "sauce": "酱料", "chili": "辣椒",
		"pepper": "胡椒", "sesame": "芝麻", "soy": "酱油",
		"miso": "味噌", "wasabi": "芥末", "lemon": "柠檬",
		"herb": "香草", "butter": "黄油", "cream": "奶油",
		"wine": "�?, "stock": "高汤",
	}
	return map.get(tag, tag)

# ============================================================
# 品阶翻译
# ============================================================

static func get_tier_chinese(tier) -> String:
	var tier_str = str(tier).to_lower()
	match tier_str:
		"bronze", "0": return "�?
		"silver", "1": return "�?
		"gold", "2": return "�?
		"diamond", "3": return "钻石"
	return "�?

# ============================================================
# 菜系翻译
# ============================================================

static func get_cuisine_chinese(cuisine: String) -> String:
	var map = {
		"chinese": "中华", "french": "法式料理",
		"japanese": "和食", "wild": "野味料理",
		"molecular": "分子料理", "dessert": "甜品",
		"fusion": "融合料理", "ingredient": "食材",
	}
	return map.get(cuisine, cuisine)

# ============================================================
# 大小翻译
# ============================================================

static func get_size_chinese(size_val: int) -> String:
	match size_val:
		1: return "小型"
		2: return "中型"
		3: return "大型"
	return "小型"

# ============================================================
# 关键词翻�?# ============================================================

static func get_keyword_chinese(kw_id: String) -> String:
	var kw = KeywordDatabase.get_keyword(kw_id)
	if not kw.is_empty():
		return kw.get("name", kw_id)
	# 备用翻译
	var map = {
		"umami": "鲜美", "char_aroma": "焦香", "plating": "摆盘",
		"knife_work": "刀�?, "spotlight": "瞩目",
		"aftertaste": "回味", "secret_recipe": "秘方",
		"greasy": "油腻", "messy": "杂乱",
		"taste_fatigue": "味觉疲劳", "dull": "沉闷",
		"fusion": "融合", "mastered": "精进",
		"rich": "浓郁", "light": "清淡",
	}
	return map.get(kw_id, kw_id)

# ============================================================
# 搭配翻译
# ============================================================

static func get_pairing_names(pairings: Array) -> String:
	if pairings.is_empty():
		return ""
	var names: Array[String] = []
	for pairing_id in pairings:
		var id_str = str(pairing_id)
		var dish = DishDatabase.get_dish(id_str)
		if not dish.is_empty():
			names.append(str(dish.get("name", id_str)))
		else:
			names.append(get_tag_chinese(id_str))
	return "�?.join(names)

# ============================================================
# 效果列表翻译
# ============================================================

static func translate_effects_list(effects: Array) -> String:
	var lines: Array[String] = []
	for eff in effects:
		if eff is Dictionary:
			var text = translate_single_effect(eff)
			if text != "":
				lines.append("�?" + text)
	if lines.is_empty():
		return "无特殊效�?
	return "\n".join(lines)

static func translate_single_effect(eff: Dictionary) -> String:
	var type = str(eff.get("type", ""))
	match type:
		"gain_keyword":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var stacks: int = int(eff.get("stacks", 1))
			return "获得%d层�?s�? % [stacks, kw]

		"consume_keyword":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var all_stacks = eff.get("all_stacks", false)
			var per_stack = eff.get("per_stack_bonus", {})
			var text = ""
			if all_stacks:
				text = "消耗所有�?s�? % kw
			else:
				var amount = int(eff.get("stacks", 1))
				text = "消�?d层�?s�? % [amount, kw]
			if not per_stack.is_empty():
				var bonus_parts: Array[String] = []
				for attr in per_stack:
					bonus_parts.append("%s+%s" % [_attr_chinese(attr), str(per_stack[attr])])
				text += "，每层：" + "�?.join(bonus_parts)
			return text

		"stat_bonus":
			var parts: Array[String] = []
			for attr in ["flavor", "presentation", "technique", "aroma"]:
				var val = eff.get(attr, 0)
				if typeof(val) == TYPE_FLOAT or typeof(val) == TYPE_INT:
					if float(val) != 0:
						parts.append("%s%+d" % [_attr_chinese(attr), int(val)])
			var cond_text = _translate_condition(eff.get("condition", {}))
			if cond_text != "":
				return cond_text + "�? + "�?.join(parts)
			# 检查是否有嵌套extra效果
			if eff.has("extra"):
				var extra_text = translate_single_effect(eff.get("extra", {}))
				if extra_text != "" and not parts.is_empty():
					return "�?.join(parts) + "�? + extra_text
			if parts.is_empty():
				return ""
			return "�?.join(parts)

		"stat_bonus_for_target":
			var parts: Array[String] = []
			for attr in ["flavor", "presentation", "technique", "aroma"]:
				var val = eff.get(attr, 0)
				if typeof(val) == TYPE_FLOAT or typeof(val) == TYPE_INT:
					if float(val) != 0:
						parts.append("%s%+d" % [_attr_chinese(attr), int(val)])
			if parts.is_empty():
				return ""
			return "相邻菜品" + "�?.join(parts)

		"gain_keyword_for_target":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var stacks: int = int(eff.get("stacks", 1))
			return "相邻菜品获得%d层�?s�? % [stacks, kw]

		"gain_keyword_per_adjacent":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var stacks: int = int(eff.get("stacks", 1))
			var cond_text = _translate_condition(eff.get("condition", {}))
			if cond_text != "":
				return "每有一�?s的相邻菜品，获得%d层�?s�? % [cond_text, stacks, kw]
			return "每个相邻菜品提供%d层�?s�? % [stacks, kw]

		"gain_keyword_scaling":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var base = int(eff.get("base_stacks", 1))
			var extra = int(eff.get("extra_per_activate", 0))
			var max_extra = int(eff.get("max_extra", 99))
			var text = "获得%d层�?s�? % [base, kw]
			if extra > 0:
				text += "，每次激活额�?%d�? % extra
				if max_extra < 99:
					text += "(上限%d)" % max_extra
			return text

		"first_activate_bonus":
			var mult = eff.get("flavor_mult", 1.0)
			return "首次上菜味道×%.1f" % float(mult)

		"flavor_mult":
			var mult = eff.get("value", eff.get("mult", 1.0))
			var cond_text = _translate_condition(eff.get("condition", {}))
			if cond_text != "":
				return "%s时味道�?.1f" % [cond_text, float(mult)]
			return "味道×%.1f" % float(mult)

		"presentation_mult":
			var mult = eff.get("value", eff.get("mult", 1.0))
			return "卖相×%.1f" % float(mult)

		"add_environment":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var stacks: int = int(eff.get("stacks", 1))
			return "环境增加%d层�?s�? % [stacks, kw]

		"trigger_environment":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var stacks: int = int(eff.get("stacks", 1))
			return "环境增加%d层�?s�? % [stacks, kw]

		"clear_environment":
			var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
			var stacks: int = int(eff.get("stacks", 1))
			var text = "清除%d层环境�?s�? % [stacks, kw]
			if eff.has("per_clear_bonus"):
				var bonus = eff.get("per_clear_bonus", {})
				var bonus_parts: Array[String] = []
				for attr in bonus:
					bonus_parts.append("%s+%s" % [_attr_chinese(attr), str(bonus[attr])])
				if not bonus_parts.is_empty():
					text += "，每层清除：" + "�?.join(bonus_parts)
			if eff.has("bonus_on_clear"):
				var on_clear = translate_single_effect(eff.get("bonus_on_clear", {}))
				if on_clear != "":
					text += "�? + on_clear
			return text

		"score":
			var parts: Array[String] = []
			for attr in ["flavor", "presentation", "technique", "aroma"]:
				var val = eff.get(attr, 0)
				if typeof(val) == TYPE_FLOAT or typeof(val) == TYPE_INT:
					if float(val) > 0:
						parts.append("%s+%d" % [_attr_chinese(attr), int(val)])
			if parts.is_empty():
				return ""
			return "产出" + "�?.join(parts)

	# 兜底：如果有keyword字段，尝试通用翻译
	if eff.has("keyword"):
		var kw: String = get_keyword_chinese(str(eff.get("keyword", "")))
		var stacks: int = int(eff.get("stacks", 1))
		return "获得%d层「%s」" % [stacks, kw]

	# ── CD 操控效果（内联字段形式）──────────────────────────────────────
	# 缩减：reduce_cooldown_self / reduce_cooldown_adjacent（旧数据格式）
	if eff.has("reduce_cooldown_self"):
		return "缩减自身冷却 %.1f 秒" % float(eff["reduce_cooldown_self"])
	if eff.has("reduce_cooldown_adjacent"):
		return "缩减相邻冷却 %.1f 秒" % float(eff["reduce_cooldown_adjacent"])

	# 加速（内联）
	if eff.has("haste"):
		var dur = float(eff.get("haste", 1.0))
		var mult = float(eff.get("multiplier", 2.0))
		return "加速自身 %.1f 秒（冷却速度×%.1f）" % [dur, mult]
	if eff.has("haste_adjacent"):
		var dur = float(eff.get("haste_adjacent", 1.0))
		var mult = float(eff.get("multiplier", 2.0))
		return "加速相邻 %.1f 秒（冷却速度×%.1f）" % [dur, mult]

	# 减速（内联）
	if eff.has("slow"):
		var dur = float(eff.get("slow", 1.0))
		var mult = float(eff.get("multiplier", 0.5))
		return "减速相邻 %.1f 秒（冷却速度×%.1f）" % [dur, mult]

	# 最终兜底：不显示原始代码
	return "特殊效果"

# ============================================================
# 触发列表翻译
# ============================================================

static func translate_triggers_list(triggers: Array) -> String:
	var lines: Array[String] = []
	for trig in triggers:
		if trig is Dictionary:
			var text = translate_single_trigger(trig)
			if text != "":
				lines.append("�?" + text)
	if lines.is_empty():
		return ""
	return "\n".join(lines)

static func translate_single_trigger(trig: Dictionary) -> String:
	var event = str(trig.get("event", ""))
	var event_text = _translate_event(event, trig)

	var cond = trig.get("condition", {})
	var cond_text = ""
	if cond is Dictionary and not cond.is_empty():
		cond_text = _translate_condition(cond)

	var effect = trig.get("effect", {})
	var effect_text = ""
	if effect is Dictionary and not effect.is_empty():
		effect_text = translate_single_effect(effect)

	# 组合
	var result = event_text
	if cond_text != "":
		result += "�? + cond_text + "�?
	if effect_text != "":
		result += effect_text

	return result

# ============================================================
# 事件翻译
# ============================================================

static func _translate_event(event: String, trig: Dictionary = {}) -> String:
	match event:
		"on_adjacent_activate":
			return "相邻菜品上菜时："
		"on_self_activate":
			return "自身上菜时："
		"on_right_activate":
			return "右侧菜品上菜时："
		"on_left_activate":
			return "左侧菜品上菜时："
		"on_tick":
			var interval = trig.get("interval", 1.0)
			return "�?.0f秒：" % float(interval)
		"on_activate":
			return "激活时�?
		"on_keyword_gain":
			var kw: String = get_keyword_chinese(str(trig.get("keyword", "")))
			return "获得�?s」时�? % kw
		"WHEN_ADJACENT_ACTIVATES":
			return "相邻菜品上菜时："
		"WHEN_LEFT_NEIGHBOR_ACTIVATES":
			return "左侧菜品上菜时："
		"WHEN_GAIN_KEYWORD":
			var kw: String = get_keyword_chinese(str(trig.get("keyword", "")))
			return "获得�?s」时�? % kw
		"WHEN_THIS_FIRST_ACTIVATES":
			return "首次上菜时："
		"FOR_EACH_STACK":
			var kw: String = get_keyword_chinese(str(trig.get("keyword", "")))
			return "每有1层�?s」：" % kw
		"IF_ADJACENT_HAS_TAG":
			var tag = get_tag_chinese(str(trig.get("tag", "")))
			return "若相邻有�?s」：" % tag
	return "触发时："

# ============================================================
# 条件翻译
# ============================================================

static func _translate_condition(cond) -> String:
	if cond == null or not (cond is Dictionary) or cond.is_empty():
		return ""

	if cond.has("has_tag"):
		return "含�?s」标�? % get_tag_chinese(str(cond["has_tag"]))

	if cond.has("has_tag_any"):
		var tags = cond["has_tag_any"]
		if tags is Array:
			var tag_names: Array[String] = []
			for t in tags:
				tag_names.append(get_tag_chinese(str(t)))
			return "含�?s」任一标签" % "�?.join(tag_names)

	if cond.has("adjacent_has_all_tags"):
		var tags = cond["adjacent_has_all_tags"]
		if tags is Array:
			var tag_names: Array[String] = []
			for t in tags:
				tag_names.append(get_tag_chinese(str(t)))
			return "相邻菜品含�?s�? % "�?.join(tag_names)

	if cond.has("keyword_stacks_gte"):
		var kw_map = cond["keyword_stacks_gte"]
		if kw_map is Dictionary:
			var parts: Array[String] = []
			for kw_id in kw_map:
				var kw_name = get_keyword_chinese(str(kw_id))
				parts.append("�?s」≥%d�? % [kw_name, int(kw_map[kw_id])])
			return "�?.join(parts)

	if cond.has("if_position"):
		var pos = str(cond["if_position"])
		match pos:
			"rightmost": return "在最右位�?
			"leftmost": return "在最左位�?
			"center": return "在中间位�?
		return "�?s位置" % pos

	if cond.has("for_each_left"):
		var left_cond = cond["for_each_left"]
		if left_cond is Dictionary and left_cond.has("size"):
			var size_name = get_size_chinese(int(left_cond["size"]))
			return "每有一个左�?s菜品" % size_name
		return "每个左侧菜品"

	if cond.has("for_each_right"):
		var right_cond = cond["for_each_right"]
		if right_cond is Dictionary and right_cond.has("size"):
			var size_name = get_size_chinese(int(right_cond["size"]))
			return "每有一个右�?s菜品" % size_name
		return "每个右侧菜品"

	if cond.has("cuisine"):
		return get_cuisine_chinese(str(cond["cuisine"]))

	if cond.has("has_technique"):
		var tech = TechniqueDatabase.get_technique(str(cond["has_technique"]))
		if not tech.is_empty():
			return "使用�?s」手�? % tech.get("name", str(cond["has_technique"]))
		return "使用特定手法"

	if cond.has("always"):
		return ""

	if cond.has("size"):
		return "%s菜品" % get_size_chinese(int(cond["size"]))

	return ""

# ============================================================
# 属性名翻译
# ============================================================

static func _attr_chinese(attr: String) -> String:
	match attr:
		"flavor": return "味道"
		"presentation": return "卖相"
		"technique": return "技�?
		"aroma": return "香气"
	return attr
