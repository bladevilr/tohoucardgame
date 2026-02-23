extends Node

var techniques: Dictionary = {}
func _ready():
	_init_techniques()

func _init_techniques():
	# ===== Chinese =====
	_add("stir_fry", "爆炒", "chinese",
		{flavor=0.25, aroma=0.15}, -0.5,
		["fierce_fire"], [],
		"以妹红不灭之炎猛火快炒，铁锅翻腾间锅气冲天——据说迷途竹林深处的夜雀食堂，正是靠这一手镇住了半个幻想乡的食客。")
	_add("braise", "红烧", "chinese",
		{flavor=0.20, presentation=0.10}, 0.0,
		["rich"], ["meat","vegetable"],
		"仿永远亭秘传之法，以浓油赤酱文火慢炖，色泽如秋日红叶谷的枫染绯红。辉夜曾言：此味可抵千年孤寂。")
	_add("steam", "蒸制", "chinese",
		{flavor=0.10, aroma=0.20, technique=0.10}, 0.0,
		["light"], [],
		"取雾之湖晨间薄雾之意，以蒸汽锁住食材本真。白玉楼的妖梦偶尔也会用此法为幽幽子备膳——清淡却回味无穷。")
	_add("wok_hei", "镬气", "chinese",
		{flavor=0.30, aroma=0.20}, -0.5,
		["stir_fried"], [],
		"传说中只有驾驭过太阳之火的灵乌路空才能催出的极致镬气。铁锅与烈焰共鸣的刹那，食材表面香气封锁，内里鲜嫩欲滴，连地灵殿的主人都为之倾倒。")

	# ===== French =====
	_add("gratin", "焗烤", "french",
		{presentation=0.25, technique=0.15}, 0.0,
		["cheese"], [],
		"红魔馆晚宴的招牌技法——咲夜在时停的间隙将芝士焗至恰好金黄，酥脆的表层下涌动着浓郁奶香，连挑剔的蕾米莉亚也赞不绝口。")
	_add("sous_vide", "低温慢煮", "french",
		{flavor=0.15, technique=0.25}, 1.0,
		[], ["meat","seafood"],
		"帕秋莉从大图书馆古籍中复原的精密烹调术，以魔法阵精准控温，长时间低温慢煮令肉质如丝绸般柔嫩。耗时虽久，成品却堪称完美。")
	_add("sauce_drizzle", "酱汁淋浇", "french",
		{presentation=0.20, aroma=0.15}, 0.0,
		[], [],
		"爱丽丝精心调配的酱汁如上海人偶的丝线般优雅垂落，在盘面勾勒出魔法阵般的纹路。据说相邻的菜品也会沾染几分华彩。")

	# ===== Japanese =====
	_add("sashimi_cut", "刺身切", "japanese",
		{technique=0.30, aroma=0.15}, 0.0,
		["raw"], ["seafood","meat"],
		"魂魄妖梦以楼观剑白楼剑双刀流斩出的极致薄切——刀刃过处，鱼肉薄如蝉翼却纹理完整，连半灵都忍不住颤抖赞叹。")
	_add("tempura", "天妇罗炸", "japanese",
		{flavor=0.20, aroma=0.20, presentation=-0.10}, 0.0,
		["crispy"], [],
		"博丽神社祭典上的人气小食。灵梦虽说是为了赛钱箱才学的手艺，但那层轻薄酥衣裹着的食材外脆内嫩，让妖怪们也心甘情愿掏钱。")
	_add("fermentation", "发酵", "japanese",
		{aroma=0.25, technique=0.10}, 0.0,
		["fermented"], [],
		"鬼族的伊吹萃香的百药枡中似乎藏着发酵的终极奥秘。以时间为引、微生物为媒，食材在静默中蜕变——味噌、酱油、清酒，皆是这古老魔法的馈赠。")
	_add("knife_art", "极精技", "japanese",
		{technique=0.35, presentation=0.10}, 0.0,
		["raw"], ["seafood","meat"],
		"射命丸文曾在《文文新闻》头版刊载的绝技——刀光快过天狗之风，食材在眨眼间被分解为精密的艺术品。唯有最上等的海鲜与肉类方配得上这般刀法。")

	# ===== Wild =====
	_add("charcoal_grill", "炭火直烤", "wild",
		{flavor=0.30, aroma=0.10, presentation=-0.15}, -1.0,
		[], ["meat"],
		"旧地狱的炭火带着地底千年的余温，将肉类烤出最原始的香气。星熊勇仪常在地底都市的宴会上豪迈地翻烤整块兽肉，粗犷却令人欲罢不能。")
	_add("smoke", "烟熏", "wild",
		{aroma=0.35, presentation=-0.10}, 0.0,
		["rich"], ["meat","seafood"],
		"魔法森林深处，雾雨魔理沙偶然发现的古法——以蘑菇木屑慢慢烟熏，层层烟气渗入食材纤维。成品带着森林与魔法的气息，香味复杂而深邃。")

	# ===== Molecular =====
	_add("spherification", "球化", "molecular",
		{presentation=0.35, technique=0.20, flavor=-0.10}, 0.0,
		["surprising"], [],
		"河城荷取将河童科技与料理融合的杰作——液滴在海藻酸钠中凝结成晶莹球体，咬破的瞬间风味在口中炸裂，如同妖怪山瀑布溅起的水花。")
	_add("liquid_nitrogen", "液氮急冻", "molecular",
		{presentation=0.25, technique=0.15}, -1.0,
		[], ["dessert","beverage","soup"],
		"永琳从月之都带回的禁忌技术，液氮倾注的刹那白雾翻涌如永远亭庭院的晨霭。食材在极寒中凝固，却保留了最鲜活的风味与色泽。")
	_add("foam", "泡沫化", "molecular",
		{presentation=0.30, aroma=0.20, flavor=-0.15}, 0.0,
		[], ["soup","sauce"],
		"这泡沫轻盈得如同幽灵乐团的旋律——入口即化，只留一缕幽香。据说普莉兹姆利巴三姐妹的演奏会上，便以这道泡沫料理作为安可曲的搭配。")
	_add("infusion", "注香", "molecular",
		{aroma=0.30, technique=0.15}, 0.0,
		["herb"], [],
		"铃仙从永远亭药草园中领悟的技法——将香草的灵魂以低温萃取注入料理之中。草药的清冽与食材的本味交织，仿佛月光穿透竹林的那一刻宁静。")

	# ===== Dessert =====
	_add("dessertify", "甜品化", "dessert",
		{presentation=0.15, technique=0.15}, 0.0,
		["dessert"], ["non_meat"],
		"红魔馆地下室里，芙兰朵露用她那毁灭与创造并存的能力，将寻常食材解构重组为精致甜品。每一份都可爱得让人不忍下口——但终究还是会被吃掉。")
	_add("flambe", "火焰炙烤", "dessert",
		{presentation=0.25, flavor=0.10}, 0.0,
		["caramel"], [],
		"藤原妹红随手点燃的蓝色火焰在甜品表面优雅地舞动，焦糖的甜香瞬间弥漫。这项看似危险的技法，在不死鸟的手中却如行云流水般自然。")
	_add("confiture", "果酱封存", "dessert",
		{flavor=0.15, presentation=0.20}, 0.0,
		["sweet"], [],
		"秋姐妹丰收季的恩赐——秋穰子与秋静叶将最饱满的果实熬煮成宝石般的果酱，封存在玻璃罐中如同妖怪山秋景的缩影。甜蜜中透着一丝季节更迭的感伤。")

func _add(id: String, display_name: String, cuisine: String, modifiers: Dictionary, cd_mod: float, tags: Array, restrictions: Array, desc: String):
	techniques[id] = {
		"id": id,
		"name": display_name,
		"cuisine": cuisine,
		"modifiers": modifiers,
		"cd_modifier": cd_mod,
		"added_tags": tags,
		"restrictions": restrictions,
		"description": desc
	}

func get_technique(id: String) -> Dictionary:
	return techniques.get(id, {})

func get_all() -> Array:
	return techniques.values()

func get_by_cuisine(cuisine: String) -> Array:
	var result: Array = []
	for t in techniques.values():
		if t.cuisine == cuisine:
			result.append(t)
	return result

func can_apply(technique_id: String, dish_tags: Array) -> bool:
	var tech = get_technique(technique_id)
	if tech.is_empty():
		return false
	if tech.restrictions.is_empty():
		return true
	for r in tech.restrictions:
		if r in dish_tags:
			return true
	return false
