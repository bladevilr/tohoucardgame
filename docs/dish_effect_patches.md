# 菜品效果补丁 - Washoku（和食）

## onigiri（饭团）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"if_position": "leftmost",
		"then": {"flavor": 3},
		"else": {"add_keyword": "umami", "keyword_stacks": 1}
	}
}],
"description": "捏得圆滚滚的可爱饭团。虽然只是简单的盐和海苔，但吃起来有一种特别安心的味道。肚子饿的时候，不论是谁都会觉得它最好吃吧。前菜，在最左侧时风味+3。"
```

## tamagoyaki（玉子烧）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"add_keyword": "plating", "keyword_stacks": 1,
		"if_adjacent_has_tag": "washoku",
		"then_bonus": {"add_keyword": "knife_work", "keyword_stacks": 1}
	}
}],
"description": "松软又香甜的厚蛋烧！金黄色的蛋卷一层一层卷起来，咬下去会有鲜美的汤汁渗出来。甜甜的味道，就像小时候的记忆一样温柔。精致菜品，相邻和食时额外+刀工。"
```

## edamame（毛豆）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"clear_env_keyword": "taste_fatigue", "stacks": 1,
		"grant_gold": 1
	}
}],
"description": "翠绿翠绿的毛豆，下酒菜的绝对王者！带着淡淡的咸味和豆子的清香，一颗接一颗地挤进嘴里，虽然简单，但根本停不下来！开胃小菜，清除疲劳+1金币。"
```

## tofu_dengaku（味噌烤豆腐）- Tier 1
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"convert_keyword": {
			"from": "greasy",
			"to": "umami",
			"ratio": 1.0
		}
	}
}],
"description": "涂满甜味噌的烤豆腐串！味噌被烤得微微焦黄，香气浓郁。豆腐热乎乎、嫩生生的，虽然简单，却有着让人意外满足的滋味。豆腐吸油，将油腻转化为鲜美。"
```

---

# 菜品效果补丁 - Yatai（夜市）

## takoyaki（章鱼烧）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"add_keyword": "char_aroma", "keyword_stacks": 1,
		"random_chance": 0.3,
		"on_success": {"add_keyword": "plating", "keyword_stacks": 1}
	}
}],
"description": "圆滚滚的章鱼烧，外面撒满了柴鱼片和海苔！咬开的瞬间，热乎乎的章鱼肉和软糯的面糊混在一起，配上酱汁和美乃滋，简直是夜市的灵魂！30%概率额外+摆盘。"
```

## yaki_imo（烤红薯）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"accumulate": {
			"counter_id": "sweetness",
			"increment": 1,
			"threshold": 2,
			"on_threshold": {"add_keyword": "aftertaste", "keyword_stacks": 3, "reset_counter": true}
		}
	}
}],
"description": "热腾腾的烤红薯，掰开的时候会冒出甜甜的蒸汽！金黄色的薯肉软糯香甜，吃起来像蜜一样。冬天抱着一个烤红薯，整个人都暖和起来了呢。越烤越甜，激活2次后爆发回味。"
```

## hashimaki（筷卷）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"copy_adjacent_keyword": {
			"target": "left",
			"keyword": "any",
			"stacks": 1
		}
	}
}],
"description": "卷在筷子上的大阪烧！边走边吃超方便，酱汁和美乃滋在上面画出漂亮的花纹。虽然看起来简单，但味道一点都不输给正宗的大阪烧哦！混合菜，复制左侧菜品的1层关键词。"
```

## taiyaki（鲷鱼烧）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"if_keyword_gte": {"keyword": "char_aroma", "stacks": 2},
		"then": {"consume_keyword": "char_aroma", "per_stack_presentation_bonus": 3.0},
		"else": {"add_keyword": "char_aroma", "keyword_stacks": 1}
	}
}],
"description": "鱼形状的可爱烧饼，里面塞满了红豆馅！外皮烤得金黄酥脆，咬下去甜蜜的红豆沙就流出来了。虽然烫嘴，但就是忍不住想一口接一口！烤制甜点，焦香≥2时消耗转化为卖相。"
```

## 夜市焦香四兄弟差异化

### yaki_tomorokoshi（烤玉米）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"add_keyword": "char_aroma", "keyword_stacks": 1,
		"chain_right": {"range": 1, "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}}
	}
}],
"description": "刷满酱油的烤玉米，每一颗玉米粒都烤得金黄焦香！咬下去嘎嘣脆，甜甜的玉米味混着酱油的咸香，越嚼越香，根本停不下来！香气扩散，向右传播1层焦香。"
```

### ikayaki（烤鱿鱼）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"add_keyword": "char_aroma", "keyword_stacks": 1,
		"if_adjacent_has_tag": "yatai",
		"then_bonus": {"reduce_cooldown_self": 0.3}
	}
}],
"description": "整只鱿鱼压在铁板上滋滋作响！烤得卷起来的鱿鱼须，刷上酱汁后香气四溢。嚼起来Q弹有劲，越嚼越有海洋的鲜味！鱿鱼快烤，相邻夜市菜时自身CD-0.3秒。"
```

### yaki_onigiri（烤饭团）- Tier 0
```gdscript
"triggers": [{
	"event": "item_activated", "condition": "self",
	"effect": {
		"add_keyword": "char_aroma", "keyword_stacks": 1,
		"if_position": "leftmost",
		"then_bonus": {"add_keyword": "umami", "keyword_stacks": 1}
	}
}],
"description": "烤得焦香的饭团，外面刷上一层酱油！米饭被烤得微微焦脆，里面还是软糯的，咬下去有种特别的满足感。简单却让人上瘾的美味！烤饭团是前菜，最左侧时额外+鲜美。"
```
