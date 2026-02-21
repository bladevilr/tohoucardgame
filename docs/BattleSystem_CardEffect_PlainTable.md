# 战斗系统与卡牌效果总表（人话版）

- 生成方式：基于仓库数据自动提取 + 规则化人话翻译（非手填）
- 统计：菜品 181 / 食材 35 / 厨具 21

## 战斗系统总览（人话版）

| 模块 | 人话说明 |
|---|---|
| 主模式 | 默认走 V2；V1 逻辑仅作兼容保留 |
| 时长 | 单场 30 秒 |
| 出菜顺序 | 先看完成时间（当前时间+冷却），同一时刻香气高者先出 |
| 评分 | 先算基础分，再叠加疲劳、偏好/厌恶、饱腹、菜系连段等修正 |
| 触发系统 | 支持条件判断、连锁、延迟、计数器等效果 |
| 食材作用 | 食材会改属性、改标签、附加特殊效果 |

## 菜品效果表（人话版）

| 类型 | ID | 名称 | 菜系 | Tier | 尺寸 | 冷却 | 标签 | 人话效果 |
|---|---|---|---|---:|---:|---:|---|---|
| 菜品 | baozi | 肉包子 | 中华 | 0 | 1 | 3.0 | ["meat", "steamed"] | 出菜时：获得1层【回味】；声望+1 |
| 菜品 | chahan | 蛋炒饭 | 中华 | 0 | 1 | 3.0 | ["rice", "stir_fried"] | 出菜时：获得1层【焦香】 |
| 菜品 | congee | 白粥 | 中华 | 0 | 1 | 3.0 | ["rice", "light", "staple"] | 出菜时：清除1层环境【油腻】 |
| 菜品 | gyoza | 煎饺 | 中华 | 0 | 1 | 3.5 | ["meat", "fried"] | 出菜时：若相邻菜品数≥2：获得2层【鲜美】；否则：获得1层【鲜美】 |
| 菜品 | hotpot_base | 火锅底料 | 中华 | 0 | 1 | 3.5 | ["spicy", "rich"] | 出菜时：获得1层【焦香】；施加1层环境【油腻】 |
| 菜品 | mapo_tofu | 麻婆豆腐 | 中华 | 0 | 1 | 4.0 | ["vegetable", "spicy", "rich"] | 出菜时：施加1层环境【油腻】 |
| 菜品 | scallion_pancake | 葱油饼 | 中华 | 0 | 1 | 3.0 | ["fried", "staple"] | 出菜时：获得1层【焦香】 |
| 菜品 | wonton_soup | 馄饨汤 | 中华 | 0 | 1 | 3.5 | ["meat", "steamed", "light"] | 出菜时：获得1层【鲜美】 |
| 菜品 | xiaolongbao | 小笼包 | 中华 | 0 | 1 | 3.5 | ["meat", "steamed", "mastered"] | 出菜时：延迟1回合后：获得2层【鲜美】 |
| 菜品 | youtiao | 油条 | 中华 | 0 | 1 | 2.5 | ["fried", "staple"] | 出菜时：获得1层【焦香】；施加1层环境【油腻】 |
| 菜品 | anmitsu | 蜜豆 | 甘味 | 0 | 1 | 3.0 | ["sweet", "light"] | 无 |
| 菜品 | daifuku | 大福 | 甘味 | 0 | 1 | 3.5 | ["sweet", "light"] | 出菜时：获得1层【摆盘】 |
| 菜品 | dango | 团子 | 甘味 | 0 | 1 | 3.0 | ["sweet", "light"] | 出菜时：获得1层【回味】 |
| 菜品 | dorayaki | 铜锣烧 | 甘味 | 0 | 1 | 3.0 | ["sweet"] | 无 |
| 菜品 | mochi | 年糕 | 甘味 | 0 | 1 | 3.0 | ["sweet", "light"] | 无 |
| 菜品 | taiyaki | 鲷鱼烧 | 甘味 | 0 | 1 | 3.0 | ["sweet", "fried"] | 无 |
| 菜品 | warabi_mochi | 蕨饼 | 甘味 | 0 | 1 | 3.0 | ["sweet", "light"] | 出菜时：清除1层轻度负面【taste_fatigue】 |
| 菜品 | yokan | 羊羹 | 甘味 | 0 | 1 | 3.5 | ["sweet", "light", "tea"] | 出菜时：获得1层【摆盘】 |
| 菜品 | edamame | 毛豆 | 和食 | 0 | 1 | 2.5 | ["vegetable", "light"] | 出菜时：清除1层环境【味觉疲劳】；金币+1 |
| 菜品 | hiyayakko | 冷豆腐 | 和食 | 0 | 1 | 2.5 | ["vegetable", "light"] | 出菜时：清除1层环境【油腻】 |
| 菜品 | miso_shiru | 味噌汤 | 和食 | 0 | 1 | 4.0 | ["soup", "umami_tag", "light"] | 出菜时：获得1层【鲜美】 |
| 菜品 | onigiri | 饭团 | 和食 | 0 | 1 | 3.0 | ["rice", "light", "staple"] | 出菜时：若在最左位：风味+3；否则：获得1层【鲜美】 |
| 菜品 | tamagoyaki | 玉子烧 | 和食 | 0 | 1 | 3.5 | ["egg", "light", "mastered"] | 出菜时：若相邻有[washoku]：获得1层【刀工】；获得1层【摆盘】 |
| 菜品 | tsukemono | 渍物 | 和食 | 0 | 1 | 3.0 | ["vegetable", "light", "fermented"] | 出菜时：清除1层环境【味觉疲劳】 |
| 菜品 | yakitori | 烤鸡肉串 | 和食 | 0 | 1 | 3.5 | ["meat", "grilled", "light"] | 出菜时：获得1层【焦香】 |
| 菜品 | amazake_latte | 甘酒拿铁 | 药膳 | 0 | 1 | 3.0 | ["sweet", "fermented", "light"] | 出菜时：清除1层环境【味觉疲劳】 |
| 菜品 | chrysanthemum_tea | 菊花茶 | 药膳 | 0 | 1 | 3.0 | ["tea", "light"] | 出菜时：获得1层【高光】；清除1层环境【迟钝】 |
| 菜品 | ginger_soup | 姜汤 | 药膳 | 0 | 1 | 3.0 | ["soup", "light"] | 出菜时：获得1层【高光】 |
| 菜品 | herbal_tea | 草药茶 | 药膳 | 0 | 1 | 3.0 | ["tea", "light"] | 出菜时：清除1层环境【味觉疲劳】 |
| 菜品 | kuzu_yu | 葛汤 | 药膳 | 0 | 1 | 3.0 | ["light"] | 出菜时：清除1层环境【迟钝】 |
| 菜品 | mushroom_tea | 蘑菇茶 | 药膳 | 0 | 1 | 3.5 | ["tea", "umami_tag"] | 出菜时：获得1层【鲜美】 |
| 菜品 | nanakusa_gayu | 七草粥 | 药膳 | 0 | 1 | 3.5 | ["rice", "light", "seasonal"] | 出菜时：清除2层环境【油腻】 |
| 菜品 | ninjin_shiri | 金平胡萝卜 | 药膳 | 0 | 1 | 3.0 | ["vegetable", "light"] | 出菜时：获得1层【高光】 |
| 菜品 | hashimaki | 筷卷 | 屋台 | 0 | 1 | 2.5 | ["fried"] | 出菜时：复制左侧菜品1层【任意关键词】 |
| 菜品 | ikayaki | 烤鱿鱼 | 屋台 | 0 | 1 | 3.0 | ["seafood", "grilled"] | 出菜时：若相邻有[yatai]：自身冷却-0.3秒；获得1层【焦香】 |
| 菜品 | taiyaki | 鲷鱼烧 | 屋台 | 0 | 1 | 3.0 | ["sweet", "fried"] | 出菜时：若【焦香】层数≥2：消耗【焦香】并转化：每层卖相+3.0；否则：获得1层【焦香】 |
| 菜品 | yaki_imo | 烤红薯 | 屋台 | 0 | 1 | 3.5 | ["vegetable", "grilled", "sweet"] | 出菜时：累计[sweetness]每次+1，达到2时：获得3层【回味】 |
| 菜品 | yaki_onigiri | 烤饭团 | 屋台 | 0 | 1 | 3.0 | ["rice", "grilled"] | 出菜时：若在最左位：获得1层【鲜美】；获得1层【焦香】 |
| 菜品 | yaki_tomorokoshi | 烤玉米 | 屋台 | 0 | 1 | 3.0 | ["vegetable", "grilled"] | 出菜时：连锁到右侧1格：获得1层【焦香】；获得1层【焦香】 |
| 菜品 | yatai_takoyaki | 章鱼烧 | 屋台 | 0 | 1 | 3.0 | ["seafood", "fried"] | 出菜时：有30%概率：获得1层【摆盘】；获得1层【焦香】 |
| 菜品 | yatai_yakitori | 烤鸡串 | 屋台 | 0 | 1 | 2.5 | ["meat", "grilled"] | 出菜时：获得1层【焦香】 |
| 菜品 | bruschetta | 意式烤面包 | 洋食 | 0 | 1 | 3.0 | ["grilled", "light"] | 无 |
| 菜品 | caesar_salad | 凯撒沙拉 | 洋食 | 0 | 1 | 3.0 | ["vegetable", "light"] | 出菜时：清除1层环境【油腻】 |
| 菜品 | carpaccio | 生牛肉薄片 | 洋食 | 0 | 1 | 3.5 | ["meat", "raw", "light"] | 出菜时：获得1层【刀工】 |
| 菜品 | consomme | 清汤 | 洋食 | 0 | 1 | 3.5 | ["soup", "light"] | 出菜时：获得1层【摆盘】 |
| 菜品 | croquettes | 可乐饼 | 洋食 | 0 | 1 | 3.5 | ["meat", "fried"] | 无 |
| 菜品 | onion_soup | 洋葱汤 | 洋食 | 0 | 1 | 4.0 | ["soup", "rich"] | 出菜时：获得1层【回味】 |
| 菜品 | quiche | 法式咸派 | 洋食 | 0 | 1 | 4.0 | ["egg", "rich"] | 无 |
| 菜品 | vichyssoise | 冷土豆浓汤 | 洋食 | 0 | 1 | 4.0 | ["soup", "light"] | 出菜时：获得1层【摆盘】 |
| 菜品 | char_siu | 叉烧 | 中华 | 1 | 1 | 5.5 | ["meat", "grilled", "rich"] | 出菜时：获得2层【焦香】 |
| 菜品 | dan_dan_noodles | 担担面 | 中华 | 1 | 1 | 5.0 | ["noodle", "spicy", "rich", "umami_tag"] | 出菜时：获得1层【鲜美】 |
| 菜品 | kung_pao_chicken | 宫保鸡丁 | 中华 | 1 | 1 | 5.0 | ["meat", "stir_fried", "spicy"] | 出菜时：获得1层【焦香】 |
| 菜品 | maoxuewang | 毛血旺 | 中华 | 1 | 2 | 6.0 | ["meat", "spicy", "rich", "stewed"] | 出菜时：获得2层【焦香】；施加1层环境【油腻】 |
| 菜品 | niurou_mian | 台式牛肉面 | 中华 | 1 | 2 | 5.5 | ["noodle", "meat", "stewed", "rich"] | 出菜时：获得1层【鲜美】；获得1层【焦香】 |
| 菜品 | spring_rolls | 春卷 | 中华 | 1 | 1 | 4.0 | ["vegetable", "fried"] | 出菜时：连锁到右侧1格：自身冷却-0.5秒 |
| 菜品 | sweet_sour_pork | 糖醋排骨 | 中华 | 1 | 2 | 6.0 | ["meat", "fried", "sweet", "sour"] | 出菜时：获得1层【回味】 |
| 菜品 | twice_cooked_pork | 回锅肉 | 中华 | 1 | 1 | 5.0 | ["meat", "stir_fried", "rich"] | 出菜时：获得2层【焦香】；施加1层环境【油腻】 |
| 菜品 | xo_sauce_noodle | XO酱炒面 | 中华 | 1 | 1 | 4.5 | ["noodle", "stir_fried", "rich"] | 出菜时：获得1层【焦香】；获得1层【回味】 |
| 菜品 | castella | 长崎蛋糕 | 甘味 | 1 | 1 | 4.5 | ["sweet", "rich"] | 出菜时：获得1层【回味】 |
| 菜品 | chestnut_kinton | 栗金团 | 甘味 | 1 | 1 | 4.0 | ["sweet", "seasonal"] | 出菜时：获得2层【回味】 |
| 菜品 | crepe | 可丽饼 | 甘味 | 1 | 1 | 3.5 | ["sweet"] | 出菜时：获得1层【摆盘】 |
| 菜品 | doll_cookie_set | 人偶饼干套装 | 甘味 | 1 | 1 | 4.5 | ["sweet", "mastered"] | 出菜时：获得2层【摆盘】 |
| 菜品 | matcha_parfait | 抹茶芭菲 | 甘味 | 1 | 2 | 5.5 | ["sweet", "tea", "light"] | 出菜时：获得2层【摆盘】 |
| 菜品 | mille_crepe | 千层蛋糕 | 甘味 | 1 | 2 | 6.0 | ["sweet", "mastered"] | 出菜时：获得1层【刀工】 |
| 菜品 | purin | 布丁 | 甘味 | 1 | 1 | 4.0 | ["sweet", "egg", "rich"] | 出菜时：获得1层【回味】 |
| 菜品 | sakura_mochi | 樱饼 | 甘味 | 1 | 1 | 4.0 | ["sweet", "seasonal", "light"] | 出菜时：获得1层【摆盘】；获得1层【回味】 |
| 菜品 | tsukimi_dango | 赏月团子 | 甘味 | 1 | 1 | 4.5 | ["sweet", "seasonal", "light"] | 出菜时：清除1层环境【味觉疲劳】 |
| 菜品 | agedashi_tofu | 炸出汁豆腐 | 和食 | 1 | 1 | 4.5 | ["vegetable", "fried", "umami_tag"] | 出菜时：获得1层【刀工】 |
| 菜品 | chawanmushi | 茶碗蒸 | 和食 | 1 | 1 | 5.0 | ["egg", "steamed", "umami_tag", "light"] | 出菜时：获得1层【鲜美】 |
| 菜品 | kitsune_udon | 狐狸乌冬 | 和食 | 1 | 2 | 5.5 | ["noodle", "umami_tag", "light"] | 出菜时：获得1层【鲜美】 |
| 菜品 | nikujaga | 肉土豆 | 和食 | 1 | 2 | 6.0 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得1层【回味】 |
| 菜品 | nimono | 煮物 | 和食 | 1 | 1 | 5.0 | ["vegetable", "stewed", "light", "umami_tag"] | 出菜时：获得1层【鲜美】；获得1层【回味】 |
| 菜品 | sashimi_moriawase | 刺身拼盘 | 和食 | 1 | 2 | 6.0 | ["seafood", "raw", "light"] | 出菜时：获得2层【刀工】 |
| 菜品 | takoyaki | 章鱼烧 | 和食 | 1 | 1 | 4.0 | ["seafood", "fried", "light"] | 出菜时：获得1层【摆盘】 |
| 菜品 | tofu_dengaku | 味噌烤豆腐 | 和食 | 1 | 1 | 4.0 | ["vegetable", "grilled", "light"] | 出菜时：将【油腻】按1.0:1转为【鲜美】 |
| 菜品 | yakizakana | 烤鱼 | 和食 | 1 | 1 | 5.0 | ["seafood", "grilled"] | 出菜时：获得1层【焦香】 |
| 菜品 | cordyceps_broth | 虫草清汤 | 药膳 | 1 | 1 | 5.5 | ["soup", "umami_tag"] | 出菜时：获得2层【鲜美】；清除1层环境【味觉疲劳】 |
| 菜品 | goji_congee | 枸杞粥 | 药膳 | 1 | 1 | 4.5 | ["rice", "light"] | 出菜时：获得1层【高光】；获得1层【回味】 |
| 菜品 | lotus_root_soup | 莲藕汤 | 药膳 | 1 | 2 | 5.5 | ["soup", "vegetable", "light"] | 出菜时：清除2层环境【油腻】 |
| 菜品 | magic_mushroom_soup | 魔法蘑菇汤 | 药膳 | 1 | 1 | 5.0 | ["soup", "umami_tag"] | 出菜时：随机获得2层关键词（鲜美、焦香、摆盘、高光） |
| 菜品 | reishi_congee | 灵芝粥 | 药膳 | 1 | 1 | 5.0 | ["rice", "light", "umami_tag"] | 出菜时：获得1层【鲜美】；获得1层【高光】 |
| 菜品 | samgyetang | 参鸡汤 | 药膳 | 1 | 2 | 6.5 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得1层【鲜美】；获得1层【回味】 |
| 菜品 | shrine_amazake | 神社甘酒 | 药膳 | 1 | 1 | 4.0 | ["sweet", "fermented", "light"] | 出菜时：清除1层环境【味觉疲劳】 |
| 菜品 | tonic_soup | 药膳补汤 | 药膳 | 1 | 1 | 5.0 | ["soup", "umami_tag", "light"] | 出菜时：获得1层【鲜美】；清除1层环境【迟钝】 |
| 菜品 | yakuzen_nabe | 药膳火锅 | 药膳 | 1 | 2 | 6.0 | ["stewed", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】 |
| 菜品 | grilled_lamprey | 烤八目鳗 | 屋台 | 1 | 1 | 5.0 | ["seafood", "grilled", "rich"] | 出菜时：获得2层【焦香】 |
| 菜品 | karaage | 炸鸡 | 屋台 | 1 | 1 | 4.0 | ["meat", "fried"] | 出菜时：施加1层环境【油腻】 |
| 菜品 | kushikatsu | 炸串 | 屋台 | 1 | 1 | 4.0 | ["meat", "fried"] | 出菜时：施加1层环境【油腻】 |
| 菜品 | monjayaki | 文字烧 | 屋台 | 1 | 1 | 4.5 | ["fried", "seafood"] | 出菜时：获得1层【焦香】 |
| 菜品 | negima | 葱鸡串 | 屋台 | 1 | 1 | 4.0 | ["meat", "grilled"] | 出菜时：获得1层【焦香】；生命+2 |
| 菜品 | okonomiyaki | 大阪烧 | 屋台 | 1 | 2 | 5.5 | ["seafood", "fried", "rich"] | 出菜时：获得2层【焦香】 |
| 菜品 | teppan_yasai | 铁板烤蔬菜 | 屋台 | 1 | 1 | 4.0 | ["vegetable", "grilled", "light"] | 出菜时：清除1层环境【油腻】 |
| 菜品 | yakisoba | 日式炒面 | 屋台 | 1 | 1 | 4.5 | ["noodle", "stir_fried"] | 出菜时：获得1层【焦香】 |
| 菜品 | yatai_ramen | 屋台拉面 | 屋台 | 1 | 2 | 5.5 | ["noodle", "rich", "umami_tag"] | 出菜时：获得1层【鲜美】；获得1层【焦香】 |
| 菜品 | chicken_fricassee | 白汁炖鸡 | 洋食 | 1 | 2 | 6.0 | ["meat", "stewed", "rich"] | 出菜时：获得1层【鲜美】；获得1层【摆盘】 |
| 菜品 | coq_au_vin | 红酒炖鸡 | 洋食 | 1 | 2 | 6.5 | ["meat", "stewed", "rich"] | 出菜时：获得1层【鲜美】；获得1层【回味】 |
| 菜品 | escargot | 法式蜗牛 | 洋食 | 1 | 1 | 4.5 | ["rich"] | 出菜时：获得1层【回味】 |
| 菜品 | gratin | 焗烤 | 洋食 | 1 | 2 | 6.0 | ["rich", "grilled"] | 出菜时：获得1层【回味】 |
| 菜品 | nicoise_salad | 尼斯沙拉 | 洋食 | 1 | 1 | 4.5 | ["seafood", "light"] | 出菜时：获得1层【摆盘】 |
| 菜品 | pasta_carbonara | 培根蛋面 | 洋食 | 1 | 2 | 5.5 | ["noodle", "egg", "rich"] | 出菜时：获得1层【鲜美】 |
| 菜品 | risotto | 意式烩饭 | 洋食 | 1 | 2 | 6.0 | ["rice", "rich", "umami_tag"] | 出菜时：获得1层【鲜美】 |
| 菜品 | terrine | 法式冻糕 | 洋食 | 1 | 1 | 5.0 | ["meat", "mastered"] | 出菜时：获得2层【摆盘】 |
| 菜品 | dim_sum_platter | 点心拼盘 | 中华 | 2 | 2 | 6.0 | ["steamed", "mastered"] | 出菜时：获得2层【摆盘】 |
| 菜品 | dongpo_pork | 东坡肉 | 中华 | 2 | 2 | 7.0 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】；施加1层环境【油腻】 |
| 菜品 | lion_head | 红烧狮子头 | 中华 | 2 | 2 | 7.0 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】；获得1层【回味】 |
| 菜品 | mapo_eggplant | 鱼香茄子 | 中华 | 2 | 1 | 5.5 | ["vegetable", "stir_fried", "rich"] | 出菜时：获得2层【回味】；施加1层环境【油腻】 |
| 菜品 | peking_duck | 北京烤鸭 | 中华 | 2 | 3 | 8.0 | ["meat", "grilled", "rich", "mastered"] | 出菜时：获得3层【焦香】 |
| 菜品 | shuizhu_yu | 水煮鱼 | 中华 | 2 | 2 | 6.5 | ["seafood", "spicy", "rich"] | 出菜时：获得2层【焦香】；获得1层【鲜美】 |
| 菜品 | steamed_fish | 清蒸鲈鱼 | 中华 | 2 | 2 | 6.5 | ["seafood", "steamed", "light", "umami_tag"] | 出菜时：获得2层【鲜美】；获得1层【刀工】 |
| 菜品 | wuxing_chaohe | 五行干炒河粉 | 中华 | 2 | 2 | 6.0 | ["noodle", "stir_fried", "rich"] | 出菜时：消耗【焦香】并转化：每层风味+4.0 |
| 菜品 | creme_brulee | 焦糖布丁 | 甘味 | 2 | 1 | 5.0 | ["sweet", "rich"] | 出菜时：获得2层【高光】 |
| 菜品 | fruit_tart | 水果挞 | 甘味 | 2 | 2 | 6.0 | ["sweet", "mastered"] | 出菜时：获得2层【摆盘】 |
| 菜品 | macaron_tower | 马卡龙塔 | 甘味 | 2 | 2 | 7.0 | ["sweet", "mastered"] | 出菜时：获得3层【摆盘】；清除1层轻度负面【presentation_penalty】 |
| 菜品 | mont_blanc | 蒙布朗 | 甘味 | 2 | 2 | 6.5 | ["sweet", "mastered", "seasonal"] | 出菜时：获得2层【摆盘】；获得1层【回味】 |
| 菜品 | moon_cake_premium | 月兔特制月饼 | 甘味 | 2 | 2 | 6.5 | ["sweet", "seasonal", "mastered"] | 出菜时：获得2层【回味】；获得1层【秘方】 |
| 菜品 | opera_cake | 歌剧院蛋糕 | 甘味 | 2 | 2 | 7.0 | ["sweet", "rich", "mastered"] | 出菜时：获得2层【回味】；获得1层【摆盘】 |
| 菜品 | strawberry_shortcake | 草莓蛋糕 | 甘味 | 2 | 2 | 6.0 | ["sweet", "light"] | 出菜时：获得2层【摆盘】 |
| 菜品 | tiramisu | 提拉米苏 | 甘味 | 2 | 2 | 6.0 | ["sweet", "rich"] | 出菜时：获得2层【回味】；获得1层【高光】 |
| 菜品 | wagashi_assort | 上生菓子拼盘 | 甘味 | 2 | 2 | 7.0 | ["sweet", "seasonal", "mastered", "light"] | 出菜时：获得3层【摆盘】 |
| 菜品 | chanko_nabe | 相扑火锅 | 和食 | 2 | 3 | 7.5 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】；获得1层【回味】 |
| 菜品 | kaisendon | 海鲜盖饭 | 和食 | 2 | 2 | 6.0 | ["seafood", "raw", "rice"] | 出菜时：获得1层【刀工】；获得1层【摆盘】 |
| 菜品 | katsudon | 炸猪排盖饭 | 和食 | 2 | 2 | 6.0 | ["meat", "fried", "rice", "rich"] | 出菜时：获得1层【焦香】；获得1层【回味】 |
| 菜品 | ochazuke | 茶泡饭 | 和食 | 2 | 1 | 4.0 | ["rice", "light", "tea"] | 出菜时：清除2层环境【油腻】 |
| 菜品 | soba_tsuyu | 冷荞麦面 | 和食 | 2 | 1 | 5.0 | ["noodle", "light", "mastered"] | 出菜时：获得1层【刀工】 |
| 菜品 | sukiyaki | 寿喜烧 | 和食 | 2 | 3 | 8.0 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得1层【鲜美】 |
| 菜品 | tempura_moriawase | 天妇罗拼盘 | 和食 | 2 | 2 | 6.5 | ["seafood", "fried", "mastered"] | 出菜时：获得1层【刀工】；获得1层【焦香】 |
| 菜品 | unagi_kabayaki | 蒲烧鳗鱼 | 和食 | 2 | 2 | 7.0 | ["seafood", "grilled", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】 |
| 菜品 | bamboo_shoot_elixir | 竹笋灵药 | 药膳 | 2 | 1 | 6.0 | ["vegetable", "mastered"] | 出菜时：获得2层【鲜美】；清除2层环境【油腻】 |
| 菜品 | black_sesame_soup | 黑芝麻糊 | 药膳 | 2 | 1 | 5.5 | ["sweet", "rich", "umami_tag"] | 出菜时：获得1层【鲜美】；获得1层【回味】 |
| 菜品 | eirin_elixir | 永琳秘药 | 药膳 | 2 | 1 | 6.0 | ["mastered"] | 出菜时：获得1层【秘方】；获得2层【高光】 |
| 菜品 | five_element_soup | 五行汤 | 药膳 | 2 | 2 | 7.0 | ["soup", "mastered", "umami_tag"] | 出菜时：获得2层【鲜美】；获得1层【刀工】 |
| 菜品 | immortal_peach | 仙桃 | 药膳 | 2 | 1 | 6.0 | ["sweet", "mastered"] | 出菜时：获得2层【回味】；获得1层【高光】 |
| 菜品 | master_spark_brew | 魔炮煎药 | 药膳 | 2 | 2 | 6.0 | ["mastered"] | 出菜时：随机获得3层关键词（鲜美、焦香、摆盘、刀工、高光、回味） |
| 菜品 | matcha_medicine | 抹茶药茶 | 药膳 | 2 | 1 | 5.0 | ["tea", "light", "mastered"] | 出菜时：获得1层【高光】；清除2层环境【味觉疲劳】 |
| 菜品 | moon_rabbit_mochi | 月兔麻糬 | 药膳 | 2 | 1 | 5.0 | ["sweet", "mastered"] | 出菜时：获得1层【秘方】；清除2层环境【迟钝】 |
| 菜品 | yin_yang_tea | 阴阳玉茶 | 药膳 | 2 | 1 | 5.0 | ["tea", "mastered", "light"] | 出菜时：清除所有环境Debuff |
| 菜品 | hiroshima_yaki | 广岛烧 | 屋台 | 2 | 2 | 6.0 | ["noodle", "fried", "rich"] | 出菜时：获得2层【焦香】；获得1层【鲜美】 |
| 菜品 | horumon_yaki | 烤内脏 | 屋台 | 2 | 1 | 5.0 | ["meat", "grilled", "rich"] | 出菜时：获得2层【焦香】；施加1层环境【油腻】 |
| 菜品 | jingisukan | 成吉思汗烤肉 | 屋台 | 2 | 2 | 6.0 | ["meat", "grilled"] | 出菜时：消耗【焦香】并转化：每层风味+4.0 |
| 菜品 | kinoko_hoiru | 锡纸烤蘑菇 | 屋台 | 2 | 1 | 5.0 | ["vegetable", "grilled", "umami_tag"] | 出菜时：获得2层【鲜美】 |
| 菜品 | motsunabe | 内脏锅 | 屋台 | 2 | 3 | 7.0 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】；施加1层环境【油腻】 |
| 菜品 | robatayaki_moriawase | 炉端烧拼盘 | 屋台 | 2 | 2 | 6.5 | ["seafood", "grilled", "mastered"] | 出菜时：获得3层【焦香】 |
| 菜品 | sanma_shioyaki | 盐烤秋刀鱼 | 屋台 | 2 | 2 | 6.5 | ["seafood", "grilled", "light"] | 出菜时：获得3层【焦香】；清除1层环境【油腻】 |
| 菜品 | tsukune | 鸡肉丸串 | 屋台 | 2 | 1 | 5.5 | ["meat", "grilled"] | 出菜时：获得2层【焦香】；获得1层【鲜美】 |
| 菜品 | wagyu_steak | 和牛牛排 | 屋台 | 2 | 2 | 7.0 | ["meat", "grilled", "rich", "mastered"] | 出菜时：获得2层【焦香】；获得1层【回味】 |
| 菜品 | afternoon_tea_set | 下午茶套装 | 洋食 | 2 | 2 | 6.5 | ["sweet", "tea", "mastered"] | 出菜时：获得3层【摆盘】 |
| 菜品 | beef_wellington | 惠灵顿牛排 | 洋食 | 2 | 3 | 8.0 | ["meat", "rich", "mastered"] | 出菜时：获得2层【摆盘】；获得2层【刀工】 |
| 菜品 | bouillabaisse | 马赛鱼汤 | 洋食 | 2 | 2 | 7.0 | ["seafood", "stewed", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】；获得1层【回味】 |
| 菜品 | duck_confit | 油封鸭 | 洋食 | 2 | 2 | 7.0 | ["meat", "rich"] | 出菜时：获得2层【回味】 |
| 菜品 | lobster_thermidor | 焗龙虾 | 洋食 | 2 | 2 | 7.5 | ["seafood", "grilled", "rich"] | 出菜时：获得2层【摆盘】；获得1层【高光】 |
| 菜品 | osso_buco | 炖小牛胫 | 洋食 | 2 | 2 | 7.5 | ["meat", "stewed", "rich", "umami_tag"] | 出菜时：获得2层【鲜美】；获得1层【回味】 |
| 菜品 | rack_of_lamb | 烤羊排 | 洋食 | 2 | 2 | 7.0 | ["meat", "grilled", "rich", "mastered"] | 出菜时：获得2层【刀工】；获得1层【摆盘】 |
| 菜品 | souffle | 舒芙蕾 | 洋食 | 2 | 1 | 5.0 | ["egg", "mastered"] | 出菜时：获得2层【高光】 |
| 菜品 | steak_frites | 牛排薯条 | 洋食 | 2 | 2 | 6.5 | ["meat", "grilled", "fried", "rich"] | 出菜时：获得1层【焦香】；获得1层【刀工】 |
| 菜品 | buddha_jumps_wall | 佛跳墙 | 中华 | 3 | 3 | 12.0 | ["seafood", "stewed", "rich", "umami_tag", "mastered"] | 出菜时：获得1层【秘方】；消耗【鲜美】并转化：每层风味+6.0 |
| 菜品 | dragon_phoenix_platter | 龙凤呈祥 | 中华 | 3 | 3 | 10.0 | ["seafood", "meat", "rich", "mastered"] | 出菜时：获得3层【焦香】；获得3层【鲜美】 |
| 菜品 | manhan_quanxi | 满汉全席 | 中华 | 3 | 3 | 14.0 | ["mastered", "rich"] | 出菜时：每有1道中华菜：风味+5.0，卖相+3.0 |
| 菜品 | alice_doll_cake | 人偶之梦 | 甘味 | 3 | 3 | 10.0 | ["sweet", "mastered"] | 出菜时：获得3层【摆盘】；获得2层【回味】；清除轻度负面：presentation_penalty |
| 菜品 | hourai_elixir_sweet | 蓬莱药膳甜点 | 甘味 | 3 | 2 | 9.0 | ["sweet", "mastered"] | 出菜时：获得3层【回味】；获得1层【秘方】 |
| 菜品 | phantasm_parfait | 幻想乡芭菲 | 甘味 | 3 | 3 | 11.0 | ["sweet", "mastered", "light"] | 出菜时：每有1道甘味菜：风味+3.0，卖相+4.0 |
| 菜品 | piece_montee | 糖艺塔 | 甘味 | 3 | 3 | 10.0 | ["sweet", "mastered"] | 出菜时：消耗【摆盘】并转化：每层风味+3.0，每层卖相+6.0 |
| 菜品 | sakuya_time_dessert | 时之结晶 | 甘味 | 3 | 2 | 9.5 | ["sweet", "mastered"] | 出菜时：获得4层【摆盘】；获得2层【高光】 |
| 菜品 | fugu_course | 河豚全席 | 和食 | 3 | 3 | 10.0 | ["seafood", "raw", "mastered", "light"] | 出菜时：消耗【刀工】并转化：每层风味+5.0 |
| 菜品 | kaiseki_hassun | 怀石八寸 | 和食 | 3 | 3 | 10.0 | ["seasonal", "mastered", "light"] | 出菜时：获得3层【摆盘】；获得2层【刀工】 |
| 菜品 | matsutake_dobin | 松茸土瓶蒸 | 和食 | 3 | 2 | 9.0 | ["seasonal", "steamed", "umami_tag", "light", "mastered"] | 出菜时：获得3层【鲜美】；清除2层环境【味觉疲劳】 |
| 菜品 | osechi_jubako | 御节料理重箱 | 和食 | 3 | 3 | 12.0 | ["seasonal", "mastered", "rich", "light"] | 出菜时：每有1道和食菜：风味+4.0 |
| 菜品 | tai_no_sugata | 鲷鱼姿造 | 和食 | 3 | 3 | 9.0 | ["seafood", "raw", "mastered"] | 出菜时：获得2层【摆盘】；获得2层【鲜美】 |
| 菜品 | hakurei_feast | 博丽之宴 | 药膳 | 3 | 3 | 12.0 | ["mastered", "light"] | 出菜时：清除所有环境Debuff；每有1道药膳菜：风味+4.0 |
| 菜品 | hourai_elixir | 蓬莱之药 | 药膳 | 3 | 2 | 10.0 | ["mastered"] | 出菜时：获得2层【秘方】；获得3层【高光】 |
| 菜品 | lunar_capital_banquet | 月都盛宴 | 药膳 | 3 | 3 | 12.0 | ["mastered", "umami_tag"] | 出菜时：获得2层【秘方】；获得3层【鲜美】；清除所有环境Debuff |
| 菜品 | philosopher_stone_dish | 贤者之石膳 | 药膳 | 3 | 3 | 11.0 | ["mastered"] | 出菜时：将全部Debuff转化为风味（每层+5.0） |
| 菜品 | magma_grill | 岩浆烧烤 | 屋台 | 3 | 3 | 10.0 | ["meat", "grilled", "rich"] | 出菜时：获得5层【焦香】；施加2层环境【油腻】 |
| 菜品 | meiling_wok_fire | 美铃的火焰锅 | 屋台 | 3 | 3 | 10.0 | ["meat", "stir_fried", "rich", "umami_tag"] | 出菜时：获得3层【鲜美】；消耗【焦香】并转化：每层风味+5.0 |
| 菜品 | mystia_secret_grill | 米斯蒂娅的秘传烧烤 | 屋台 | 3 | 3 | 10.5 | ["seafood", "grilled", "mastered", "umami_tag"] | 出菜时：获得3层【焦香】；获得2层【鲜美】；获得1层【秘方】 |
| 菜品 | phoenix_rebirth_skewer | 不死鸟之串 | 屋台 | 3 | 2 | 9.0 | ["meat", "grilled", "mastered"] | 出菜时：获得4层【焦香】；本回合首次退场后复活 |
| 菜品 | sparrow_night_feast | 夜雀之宴 | 屋台 | 3 | 3 | 10.0 | ["seafood", "grilled", "mastered"] | 出菜时：获得1层【秘方】；消耗【焦香】并转化：每层风味+6.0 |
| 菜品 | teppanyaki_course | 铁板烧全席 | 屋台 | 3 | 3 | 11.0 | ["meat", "seafood", "grilled", "rich", "mastered"] | 出菜时：每有1道屋台菜：风味+4.0，香气+3.0 |
| 菜品 | chateaubriand_rossini | 罗西尼牛排 | 洋食 | 3 | 3 | 10.0 | ["meat", "rich", "mastered"] | 出菜时：获得3层【刀工】；获得2层【高光】 |
| 菜品 | foie_gras_truffle | 松露鹅肝 | 洋食 | 3 | 2 | 9.0 | ["meat", "rich", "mastered"] | 出菜时：获得3层【摆盘】；获得1层【秘方】 |
| 菜品 | full_course_francais | 法式全席 | 洋食 | 3 | 3 | 12.0 | ["mastered", "rich"] | 出菜时：每有1道洋食菜：风味+3.0，卖相+5.0 |
| 菜品 | grand_dessert_assiette | 大甜品盘 | 洋食 | 3 | 3 | 10.0 | ["sweet", "mastered"] | 出菜时：消耗【摆盘】并转化：每层风味+3.0，每层卖相+5.0 |

## 食材效果表（人话版）

| 类型 | ID | 名称 | Tier | 价格 | 人话效果 |
|---|---|---|---:|---:|---|
| 食材 | butter | 发酵黄油 | 0 | 1 | 风味+3；卖相+2；添加标签：rich；需包含标签：light；亲和菜系：洋食 |
| 食材 | chili_flakes | 辣椒碎 | 0 | 1 | 风味+3；香气+2；添加标签：spicy |
| 食材 | garlic | 极品大蒜 | 0 | 1 | 风味+3；香气+2 |
| 食材 | green_onion | 九条葱 | 0 | 1 | 风味+2；香气+3；亲和菜系：和食 |
| 食材 | mirin | 味醂 | 0 | 1 | 风味+2；卖相+2；添加标签：light；亲和菜系：和食 |
| 食材 | salt | 博丽盐 | 0 | 1 | 风味+4 |
| 食材 | sesame_oil | 麻油 | 0 | 1 | 风味+1；香气+4；亲和菜系：中华 |
| 食材 | soy_sauce | 酱油 | 0 | 1 | 风味+2；卖相+1；香气+2；添加标签：umami_tag；亲和菜系：中华 |
| 食材 | sugar | 和三盆糖 | 0 | 1 | 风味+2；卖相+3；添加标签：sweet；亲和菜系：甘味 |
| 食材 | vinegar | 黑醋 | 0 | 1 | 风味+3；技法+1；添加标签：sour；亲和菜系：中华 |
| 食材 | bonito_flakes | 鰹節 | 1 | 2 | 风味+3；技法+2；香气+4；添加标签：umami_tag、fermented；亲和菜系：和食 |
| 食材 | chili_oil | 红油 | 1 | 2 | 风味+6；香气+3；添加标签：spicy、rich；需包含标签：light；亲和菜系：中华 |
| 食材 | cream | 生奶油 | 1 | 2 | 风味+3；卖相+4；技法+1；添加标签：rich、sweet；亲和菜系：洋食 |
| 食材 | dashi_kombu | 利尻昆布 | 1 | 2 | 风味+4；技法+2；香气+3；添加标签：umami_tag；亲和菜系：和食 |
| 食材 | ginger | 老姜 | 1 | 2 | 风味+3；香气+4；移除标签：greasy；对决开始时：清除 1 层【油腻】 |
| 食材 | herb_mix | 普罗旺斯香草 | 1 | 2 | 卖相+2；香气+6；添加标签：herb；亲和菜系：洋食 |
| 食材 | medicinal_herb | 灵芝 | 1 | 2 | 风味+2；技法+4；香气+3；添加标签：medicinal；亲和菜系：药膳 |
| 食材 | miso_paste | 八丁味噌 | 1 | 2 | 风味+5；香气+3；添加标签：fermented、umami_tag、rich；亲和菜系：和食 |
| 食材 | saffron | 番红花 | 1 | 2 | 风味+3；卖相+6；亲和菜系：洋食 |
| 食材 | sichuan_pepper | 花椒 | 1 | 2 | 风味+4；香气+5；添加标签：spicy、numbing；亲和菜系：中华 |
| 食材 | truffle_oil | 松露油 | 1 | 2 | 风味+5；卖相+2；香气+4；添加标签：rich；亲和菜系：洋食 |
| 食材 | wasabi | 本山葵 | 1 | 2 | 风味+4；技法+3；香气+2；添加标签：spicy；亲和菜系：和食 |
| 食材 | aged_sake | 百年古酒 | 2 | 2 | 风味+5；技法+3；香气+7；添加标签：fermented、rich；亲和菜系：和食 |
| 食材 | black_truffle | 黑松露 | 2 | 2 | 风味+7；香气+8；添加标签：rich、rare、umami_tag；亲和菜系：洋食 |
| 食材 | celestial_peach | 天人之桃 | 2 | 2 | 风味+6；卖相+6；香气+3；添加标签：sweet、rare；亲和菜系：甘味 |
| 食材 | dragon_liver | 龙肝 | 2 | 2 | 风味+8；技法+5；添加标签：rich、rare |
| 食材 | ghost_pepper | 灵界辣椒 | 2 | 2 | 风味+10；香气+4；添加标签：spicy、rare；首次激活时：添加 2 层【油腻】 |
| 食材 | golden_egg | 凤凰卵 | 2 | 2 | 风味+7；卖相+5；技法+3；添加标签：egg、rare |
| 食材 | moonlight_salt | 月光盐 | 2 | 2 | 风味+6；卖相+4；香气+4；对决开始时：每种环境 Debuff 各清 1 层 |
| 食材 | youkai_mushroom | 妖怪茸 | 2 | 2 | 风味+5；技法+5；香气+5；添加标签：medicinal、rare；亲和菜系：药膳 |
| 食材 | ambrosia | 神馔 | 3 | 2 | 风味+12；卖相+8；技法+5；香气+8；添加标签：rare、divine |
| 食材 | hourai_elixir | 蓬莱之药 | 3 | 2 | 风味+10；技法+8；香气+8；添加标签：medicinal、rare、divine；对决开始时：获得 1 层【秘方】；亲和菜系：药膳 |
| 食材 | lunar_dew | 月露 | 3 | 2 | 风味+5；卖相+10；香气+10；添加标签：rare、light、divine |
| 食材 | void_essence | 虚空精华 | 3 | 2 | 风味+8；技法+10；香气+6；添加标签：rare；首次激活：风味分数 x2 |
| 食材 | yatagarasu_flame | 八咫鸦之炎 | 3 | 2 | 风味+15；香气+5；添加标签：spicy、rare、grilled；移除标签：light；对决开始时：获得 3 层【焦香】；亲和菜系：屋台 |

## 厨具效果表（人话版）

| 类型 | ID | 名称 | Tier | 类别 | 核心属性 | 人话效果 |
|---|---|---|---|---|---|---|
| 厨具 | mortar | 石臼 | bronze | tool | {aroma=3, flavor=2} | 研磨香料时香气+6，风味+3；芳香食材香气+3 |
| 厨具 | porcelain_set | 精品瓷盘套装 | bronze | container | {presentation=5} | 所有菜品卖相+3；获得【摆盘】时额外+1层 |
| 厨具 | santoku | 三德刀 | bronze | knife | {flavor=3, technique=2} | 切蔬菜时风味+5 |
| 厨具 | boning_knife | 剔骨刀 | silver | knife | {flavor=6, technique=3} | 处理肉类时风味+8；大菜品上菜时获得1层【鲜美】 |
| 厨具 | cast_iron_pot | 铸铁锅 | silver | pot | {flavor=5, aroma=3} | 红烧时风味+8；爆炒时香气+5；炒菜CD-0.5s |
| 厨具 | chef_knife | 主厨刀 | silver | knife | {flavor=4, technique=4, aroma=2} | 所有菜品技巧+3；法餐菜品首次上菜时获得1层【秘方】 |
| 厨具 | chinese_cleaver | 中式片刀 | silver | knife | {flavor=5, technique=4} | 制作中华料理时风味+6 |
| 厨具 | copper_pot | 铜锅 | silver | pot | {technique=5, presentation=3} | 制作法式料理时技巧+6 |
| 厨具 | donabe | 土锅 | silver | pot | {flavor=4, aroma=4} | 煮汤时风味+7，香气+5 |
| 厨具 | fierce_stove | 猛火灶 | silver | equipment | {flavor=5, aroma=4} | 中餐菜品风味+8，CD-0.5s；猛火菜品香气+6；≥3中餐：爆炒手法效果+25% |
| 厨具 | homogenizer | 均质机 | silver | equipment | {technique=5, presentation=3} | 泡沫化时卖相+8，技巧+5；球化时技巧+6；酱类菜品卖相+3 |
| 厨具 | smoke_gun | 烟枪 | silver | equipment | {aroma=6, flavor=2} | 烟熏时香气+10，风味+5；浓郁菜品香气+4 |
| 厨具 | sous_vide_machine | 低温慢煮机 | silver | equipment | {technique=6, flavor=3} | 低温慢煮时风味+10，技巧+5；获得【鲜美】时CD-0.3s |
| 厨具 | steamer | 蒸笼 | silver | equipment | {flavor=4, aroma=4, technique=2} | 蒸制时风味+6，香气+6；清淡菜品香气+4 |
| 厨具 | thermometer | 温度计 | silver | tool | {technique=5} | 低温慢煮时技巧+6；液氮急冻时技巧+5 |
| 厨具 | vacuum_sealer | 真空包装机 | silver | equipment | {technique=4, flavor=3} | 低温慢煮时风味+6，技巧+4 |
| 厨具 | binchotan_grill | 备长炭烤炉 | gold | equipment | {flavor=7, aroma=6} | 炭火直烤时风味+12，香气+8；烤肉时风味+5 |
| 厨具 | liquid_nitrogen_tank | 液氮罐 | gold | equipment | {presentation=7, technique=5} | 液氮急冻时卖相+12，技巧+6；分子料理卖相+5 |
| 厨具 | rotary_evaporator | 旋转蒸发仪 | gold | equipment | {technique=8, aroma=5} | 分子料理技巧+8，香气+6；惊艳菜品卖相+8 |
| 厨具 | truffle_slicer | 松露刨片器 | gold | tool | {aroma=6, presentation=5, flavor=4} | 含松露菜品香气+15，风味+10；法式料理卖相+6；浓郁菜品风味+4 |
| 厨具 | yanagiba | 柳刃包丁 | gold | knife | {technique=8, aroma=4} | 处理刺身时技巧+10；使用刺身切时香气+8；≥3日料：所有日料香气+10% |

