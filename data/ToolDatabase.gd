extends Node

var tools: Dictionary = {}
func _ready():
	_init_tools()

func _init_tools():
	# === Knives ===
	_add("santoku", "三德刀", "bronze", "knife",
		{flavor=3, technique=2},
		[{trigger="on_activate", condition="has_tag:vegetable", effect="flavor+5", desc="切蔬菜时风味+5",
		 keyword_effect={type="gain_keyword", keyword="knife_work", stacks=1}}],
		"万能家用刀，蔬菜处理得心应手。切蔬菜时获得1层【刀工】")

	_add("yanagiba", "柳刃包丁", "gold", "knife",
		{technique=8, aroma=4},
		[
			{trigger="on_activate", condition="has_tag:raw", effect="technique+10", desc="处理刺身时技巧+10",
			 keyword_effect={type="gain_keyword", keyword="knife_work", stacks=2}},
			{trigger="on_activate", condition="has_technique:sashimi_cut", effect="aroma+8", desc="使用刺身切时香气+8"},
			{trigger="synergy", condition="cuisine_count:japanese:3", effect="japanese_aroma+0.10", desc="≥3日料：所有日料香气+10%"}
		],
		"日式刺身专用刀，极致锋利。生食菜品上菜时获得2层【刀工】")

	_add("chinese_cleaver", "中式片刀", "silver", "knife",
		{flavor=5, technique=4},
		[{trigger="on_activate", condition="cuisine:chinese", effect="flavor+6", desc="制作中华料理时风味+6",
		 keyword_effect={type="gain_keyword", keyword="knife_work", stacks=1}}],
		"中式片刀，片切两用。中餐菜品上菜时获得1层【刀工】")

	_add("chef_knife", "主厨刀", "silver", "knife",
		{flavor=4, technique=4, aroma=2},
		[
			{trigger="on_activate", condition="always", effect="technique+3", desc="所有菜品技巧+3"},
			{trigger="on_activate", condition="cuisine:french", effect="", desc="法餐菜品首次上菜时获得1层【秘方】",
			 keyword_effect={type="gain_keyword", keyword="secret_recipe", stacks=1}, first_only=true}
		],
		"西式主厨刀，全能之选。法餐菜品首次上菜时获得1层【秘方】")

	_add("boning_knife", "剔骨刀", "silver", "knife",
		{flavor=6, technique=3},
		[
			{trigger="on_activate", condition="has_tag:meat", effect="flavor+8", desc="处理肉类时风味+8"},
			{trigger="on_activate", condition="size:3", effect="", desc="大菜品上菜时获得1层【鲜美】",
			 keyword_effect={type="gain_keyword", keyword="umami", stacks=1}}
		],
		"剔骨专用，肉类处理利器。大菜品上菜时获得1层【鲜美】")

	# === Pots & Heat Sources ===
	_add("cast_iron_pot", "铸铁锅", "silver", "pot",
		{flavor=5, aroma=3},
		[
			{trigger="on_activate", condition="has_technique:braise", effect="flavor+8", desc="红烧时风味+8"},
			{trigger="on_activate", condition="has_technique:stir_fry", effect="aroma+5", desc="爆炒时香气+5",
			 keyword_effect={type="gain_keyword", keyword="char_aroma", stacks=1}},
			{trigger="on_activate", condition="has_tag:stir_fried", effect="cd-0.5", desc="炒菜CD-0.5s"}
		],
		"铸铁重锅，蓄热均匀。炒菜上菜时获得1层【焦香】")

	_add("copper_pot", "铜锅", "silver", "pot",
		{technique=5, presentation=3},
		[
			{trigger="on_activate", condition="cuisine:french", effect="technique+6", desc="制作法式料理时技巧+6",
			 keyword_effect={type="gain_keyword", keyword="plating", stacks=1}}
		],
		"铜制锅具，导热精准。法餐菜品上菜时获得1层【摆盘】")

	_add("donabe", "土锅", "silver", "pot",
		{flavor=4, aroma=4},
		[
			{trigger="on_activate", condition="has_tag:soup", effect="flavor+7,aroma+5", desc="煮汤时风味+7，香气+5",
			 keyword_effect={type="gain_keyword", keyword="aftertaste", stacks=1}}
		],
		"日式土锅，慢炖入味。汤类上菜时获得1层【回味】")

	_add("sous_vide_machine", "低温慢煮机", "silver", "equipment",
		{technique=6, flavor=3},
		[
			{trigger="on_activate", condition="has_technique:sous_vide", effect="flavor+10,technique+5", desc="低温慢煮时风味+10，技巧+5",
			 keyword_effect={type="gain_keyword", keyword="umami", stacks=1}},
			{trigger="on_keyword_gain", condition="keyword:umami", effect="cd-0.3", desc="获得【鲜美】时CD-0.3s"}
		],
		"精准温控，低温慢煮专用。慢煮菜品上菜时获得1层【鲜美】")

	_add("binchotan_grill", "备长炭烤炉", "gold", "equipment",
		{flavor=7, aroma=6},
		[
			{trigger="on_activate", condition="has_technique:charcoal_grill", effect="flavor+12,aroma+8", desc="炭火直烤时风味+12，香气+8",
			 keyword_effect={type="gain_keyword", keyword="char_aroma", stacks=2}},
			{trigger="on_activate", condition="has_tag:meat", effect="flavor+5", desc="烤肉时风味+5"}
		],
		"备长炭烤炉，远红外线均匀加热。烤菜品上菜时获得2层【焦香】")

	_add("fierce_stove", "猛火灶", "silver", "equipment",
		{flavor=5, aroma=4},
		[
			{trigger="on_activate", condition="cuisine:chinese", effect="flavor+8,cd-0.5", desc="中餐菜品风味+8，CD-0.5s",
			 keyword_effect={type="gain_keyword", keyword="char_aroma", stacks=1}},
			{trigger="on_activate", condition="has_tag:fierce_fire", effect="aroma+6", desc="猛火菜品香气+6"},
			{trigger="synergy", condition="cuisine_count:chinese:3", effect="stir_fry_bonus+0.25", desc="≥3中餐：爆炒手法效果+25%"}
		],
		"猛火灶台，锅气逼人。中餐菜品上菜时获得1层【焦香】")

	# === Molecular Equipment ===
	_add("liquid_nitrogen_tank", "液氮罐", "gold", "equipment",
		{presentation=7, technique=5},
		[
			{trigger="on_activate", condition="has_technique:liquid_nitrogen", effect="presentation+12,technique+6", desc="液氮急冻时卖相+12，技巧+6"},
			{trigger="on_activate", condition="cuisine:molecular", effect="presentation+5", desc="分子料理卖相+5",
			 keyword_effect={type="gain_keyword", keyword="plating", stacks=1}}
		],
		"液氮储罐，分子料理核心设备。分子菜品上菜时获得1层【摆盘】")

	_add("rotary_evaporator", "旋转蒸发仪", "gold", "equipment",
		{technique=8, aroma=5},
		[
			{trigger="on_activate", condition="cuisine:molecular", effect="technique+8,aroma+6", desc="分子料理技巧+8，香气+6"},
			{trigger="on_activate", condition="has_tag:surprising", effect="presentation+8", desc="惊艳菜品卖相+8",
			 keyword_effect={type="gain_keyword", keyword="plating", stacks=1}}
		],
		"旋转蒸发仪，萃取精华香气。惊艳菜品上菜时获得1层【摆盘】")

	_add("vacuum_sealer", "真空包装机", "silver", "equipment",
		{technique=4, flavor=3},
		[{trigger="on_activate", condition="has_technique:sous_vide", effect="flavor+6,technique+4", desc="低温慢煮时风味+6，技巧+4"}],
		"真空密封，锁住风味")

	_add("smoke_gun", "烟枪", "silver", "equipment",
		{aroma=6, flavor=2},
		[
			{trigger="on_activate", condition="has_technique:smoke", effect="aroma+10,flavor+5", desc="烟熏时香气+10，风味+5",
			 keyword_effect={type="gain_keyword", keyword="char_aroma", stacks=1}},
			{trigger="on_activate", condition="has_tag:rich", effect="aroma+4", desc="浓郁菜品香气+4"}
		],
		"冷烟枪，精准烟熏。烟熏菜品上菜时获得1层【焦香】")

	_add("homogenizer", "均质机", "silver", "equipment",
		{technique=5, presentation=3},
		[
			{trigger="on_activate", condition="has_technique:foam", effect="presentation+8,technique+5", desc="泡沫化时卖相+8，技巧+5"},
			{trigger="on_activate", condition="has_technique:spherification", effect="technique+6", desc="球化时技巧+6"},
			{trigger="on_activate", condition="has_tag:sauce", effect="presentation+3", desc="酱类菜品卖相+3",
			 keyword_effect={type="gain_keyword", keyword="plating", stacks=1}}
		],
		"均质乳化，质地细腻。酱类菜品上菜时获得1层【摆盘】")

	# === Containers & Misc ===
	_add("mortar", "石臼", "bronze", "tool",
		{aroma=3, flavor=2},
		[
			{trigger="on_activate", condition="has_tag:spice", effect="aroma+6,flavor+3", desc="研磨香料时香气+6，风味+3"},
			{trigger="on_activate", condition="has_tag:aromatic", effect="aroma+3", desc="芳香食材香气+3",
			 keyword_effect={type="gain_keyword", keyword="char_aroma", stacks=1}}
		],
		"石臼研磨，释放香气。芳香食材上菜时获得1层【焦香】")

	_add("steamer", "蒸笼", "silver", "equipment",
		{flavor=4, aroma=4, technique=2},
		[
			{trigger="on_activate", condition="has_technique:steam", effect="flavor+6,aroma+6", desc="蒸制时风味+6，香气+6",
			 keyword_effect={type="gain_keyword", keyword="aftertaste", stacks=1}},
			{trigger="on_activate", condition="has_tag:light", effect="aroma+4", desc="清淡菜品香气+4"}
		],
		"竹制蒸笼，蒸汽均匀。蒸制菜品上菜时获得1层【回味】")

	_add("porcelain_set", "精品瓷盘套装", "bronze", "container",
		{presentation=5},
		[
			{trigger="on_activate", condition="always", effect="presentation+3", desc="所有菜品卖相+3"},
			{trigger="on_keyword_gain", condition="keyword:plating", effect="extra_stack+1", desc="获得【摆盘】时额外+1层",
			 keyword_effect={type="gain_keyword", keyword="plating", stacks=1}}
		],
		"精美瓷盘，提升摆盘效果。获得【摆盘】时额外获得1层")

	_add("thermometer", "温度计", "silver", "tool",
		{technique=5},
		[
			{trigger="on_activate", condition="has_technique:sous_vide", effect="technique+6", desc="低温慢煮时技巧+6"},
			{trigger="on_activate", condition="has_technique:liquid_nitrogen", effect="technique+5", desc="液氮急冻时技巧+5"}
		],
		"精准温度计，掌控火候")

	_add("truffle_slicer", "松露刨片器", "gold", "tool",
		{aroma=6, presentation=5, flavor=4},
		[
			{trigger="on_activate", condition="has_tag:truffle", effect="aroma+15,flavor+10", desc="含松露菜品香气+15，风味+10"},
			{trigger="on_activate", condition="cuisine:french", effect="presentation+6", desc="法式料理卖相+6"},
			{trigger="on_activate", condition="has_tag:rich", effect="flavor+4", desc="浓郁菜品风味+4",
			 keyword_effect={type="gain_keyword", keyword="umami", stacks=1}}
		],
		"松露专用刨片器，薄片飘香。浓郁菜品上菜时获得1层【鲜美】")

func _add(id: String, display_name: String, tier: String, category: String, core: Dictionary, triggers: Array, desc: String):
	tools[id] = {
		"id": id,
		"name": display_name,
		"tier": tier,
		"category": category,
		"core_effect": core,
		"triggers": triggers,
		"description": desc
	}

func get_tool(id: String) -> Dictionary:
	return tools.get(id, {})

func get_all() -> Array:
	return tools.values()

func get_by_tier(tier: String) -> Array:
	var result: Array = []
	for t in tools.values():
		if t.tier == tier:
			result.append(t)
	return result

func get_by_category(category: String) -> Array:
	var result: Array = []
	for t in tools.values():
		if t.category == category:
			result.append(t)
	return result

func get_tier_weight(tier: String) -> float:
	match tier:
		"bronze": return 1.0
		"silver": return 0.6
		"gold": return 0.25
	return 1.0
