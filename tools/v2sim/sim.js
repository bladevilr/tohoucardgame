// ============================================================
// 东方大巴扎 V2 数值原型模拟器
// 需求链 + 条件饱腹度 + 味觉阈值(含上瘾反转) + 简化得分
// ============================================================
"use strict";

// ---- DISH DATABASE (condensed from 181 dishes) ----
// format: [id, name, cuisine, tier, size, cd, flavor, pres, tech, aroma, tags[]]
const RAW_DISHES = [
// CHUUKA T0
["chahan","炒飯","chuuka",0,1,3,6,2,3,4,["rice","stir_fried"]],
["gyoza","煎饺","chuuka",0,1,3,5,3,4,4,["meat","fried"]],
["mapo_tofu","麻婆豆腐","chuuka",0,1,3,8,2,3,5,["vegetable","spicy","rich"]],
["xiaolongbao","小笼包","chuuka",0,1,3,6,5,5,3,["meat","steamed","mastered"]],
["congee","白粥","chuuka",0,1,3,4,1,2,3,["rice","light","staple"]],
["baozi","肉包子","chuuka",0,1,3,5,2,3,4,["meat","steamed"]],
["hotpot_base","火锅底料","chuuka",0,1,3,6,1,2,6,["spicy","rich"]],
["scallion_pancake","葱油饼","chuuka",0,1,3,5,2,4,5,["vegetable","fried"]],
["wonton_soup","馄饨汤","chuuka",0,1,3,6,3,3,4,["meat","steamed","light","soup"]],
["youtiao","油条","chuuka",0,1,3,4,2,3,5,["fried","staple"]],
// CHUUKA T1
["kung_pao_chicken","宫保鸡丁","chuuka",1,1,5,10,4,6,7,["meat","stir_fried","spicy"]],
["sweet_sour_pork","糖醋排骨","chuuka",1,2,6,11,6,5,6,["meat","fried","sweet","sour"]],
["dan_dan_noodles","担担面","chuuka",1,1,5,9,3,5,8,["noodle","spicy","rich","umami_tag"]],
["char_siu","叉烧","chuuka",1,1,5,10,5,4,8,["meat","grilled","rich"]],
["spring_rolls","春卷","chuuka",1,1,5,7,5,5,5,["vegetable","fried"]],
["niurou_mian","台式牛肉面","chuuka",1,2,6,10,3,5,9,["noodle","meat","stewed","rich"]],
["maoxuewang","毛血旺","chuuka",1,2,6,11,3,4,8,["meat","spicy","rich","stewed"]],
["xo_sauce_noodle","XO酱炒面","chuuka",1,1,5,8,4,5,7,["noodle","stir_fried","rich"]],
["twice_cooked_pork","回锅肉","chuuka",1,1,5,10,4,6,7,["meat","stir_fried","rich"]],
// CHUUKA T2
["peking_duck","北京烤鸭","chuuka",2,3,9,18,10,12,14,["meat","grilled","rich","mastered"]],
["dongpo_pork","东坡肉","chuuka",2,2,7,16,6,8,10,["meat","stewed","rich","umami_tag"]],
["wuxing_chaohe","五行干炒河粉","chuuka",2,2,7,14,4,8,12,["noodle","stir_fried","rich"]],
["steamed_fish","清蒸鲈鱼","chuuka",2,2,7,13,8,10,9,["seafood","steamed","light","umami_tag"]],
["dim_sum_platter","点心拼盘","chuuka",2,2,7,12,10,10,6,["steamed","mastered"]],
["shuizhu_yu","水煮鱼","chuuka",2,2,7,15,5,7,11,["seafood","spicy","rich"]],
["lion_head","红烧狮子头","chuuka",2,2,7,14,6,8,10,["meat","stewed","rich","umami_tag"]],
["mapo_eggplant","鱼香茄子","chuuka",2,1,5,12,5,7,9,["vegetable","stir_fried","rich"]],
// CHUUKA T3
["buddha_jumps_wall","佛跳墙","chuuka",3,3,12,24,10,12,16,["seafood","stewed","rich","umami_tag","mastered"]],
["manhan_quanxi","满汉全席","chuuka",3,3,12,20,16,14,14,["mastered","rich"]],
["dragon_phoenix","龙凤呈祥","chuuka",3,3,12,22,14,10,12,["seafood","meat","rich","mastered"]],
// WASHOKU T0
["onigiri","饭团","washoku",0,1,3,6,2,2,3,["rice","light","staple"]],
["miso_shiru","味噌汤","washoku",0,1,3,5,2,3,5,["soup","umami_tag","light"]],
["tamagoyaki","玉子烧","washoku",0,1,3,5,4,4,2,["egg","light","mastered"]],
["tsukemono","渍物","washoku",0,1,3,4,3,2,4,["vegetable","light","fermented","sour"]],
["edamame","毛豆","washoku",0,1,3,3,2,1,3,["vegetable","light"]],
["hiyayakko","冷豆腐","washoku",0,1,3,3,3,1,3,["vegetable","light"]],
["yakitori_w","烤鸡串","washoku",0,1,3,7,3,3,6,["meat","grilled","light"]],
// WASHOKU T1
["sashimi","刺身拼盘","washoku",1,2,6,12,8,10,5,["seafood","raw","light"]],
["chawanmushi","茶碗蒸","washoku",1,1,5,8,6,6,6,["egg","steamed","umami_tag","light"]],
["yakizakana","烤鱼","washoku",1,1,5,9,4,5,8,["seafood","grilled"]],
["nikujaga","肉土豆","washoku",1,2,6,10,4,5,7,["meat","stewed","rich","umami_tag"]],
["tofu_dengaku","味噌烤豆腐","washoku",1,1,5,7,5,4,5,["vegetable","grilled","light"]],
["nimono","煮物","washoku",1,1,5,8,5,5,6,["vegetable","stewed","light","umami_tag"]],
["kitsune_udon","狐狸乌冬","washoku",1,2,6,9,4,4,8,["noodle","umami_tag","light"]],
["agedashi_tofu","炸出汁豆腐","washoku",1,1,5,7,6,6,5,["vegetable","fried","umami_tag"]],
["takoyaki_w","章鱼烧","washoku",1,1,5,8,5,5,7,["seafood","fried","light"]],
// WASHOKU T2
["tempura","天妇罗拼盘","washoku",2,2,7,14,10,12,8,["seafood","fried","mastered"]],
["unagi","蒲烧鳗鱼","washoku",2,2,7,16,6,8,12,["seafood","grilled","rich","umami_tag"]],
["sukiyaki","寿喜烧","washoku",2,3,9,18,6,6,10,["meat","stewed","rich","umami_tag"]],
["ochazuke","茶泡饭","washoku",2,1,5,10,3,4,8,["rice","light","tea"]],
["soba_tsuyu","冷荞麦面","washoku",2,1,5,11,7,8,6,["noodle","light","mastered"]],
["kaisendon","海鲜盖饭","washoku",2,2,7,13,10,8,7,["seafood","raw","rice"]],
["chanko_nabe","相扑火锅","washoku",2,3,9,15,4,5,12,["meat","stewed","rich","umami_tag"]],
["katsudon","炸猪排盖饭","washoku",2,2,7,14,5,7,9,["meat","fried","rice","rich"]],
// WASHOKU T3
["kaiseki","怀石八寸","washoku",3,3,12,20,18,16,12,["seasonal","mastered","light"]],
["fugu_course","河豚全席","washoku",3,3,12,22,14,18,10,["seafood","raw","mastered","light"]],
["tai_sugata","鲷鱼姿造","washoku",3,3,12,18,20,14,8,["seafood","raw","mastered"]],
["osechi","御节料理","washoku",3,3,12,16,16,12,14,["seasonal","mastered","rich","light"]],
["matsutake","松茸土瓶蒸","washoku",3,2,9,19,15,13,16,["seasonal","steamed","umami_tag","light","mastered"]],
// YOUSHOKU T0
["consomme","清汤","youshoku",0,1,3,5,4,4,3,["soup","light"]],
["quiche","法式咸派","youshoku",0,1,3,6,4,3,4,["egg","rich"]],
["caesar_salad","凯撒沙拉","youshoku",0,1,3,4,5,3,2,["vegetable","light"]],
["bruschetta","意式烤面包","youshoku",0,1,3,5,4,2,4,["grilled","light"]],
["vichyssoise","冷土豆浓汤","youshoku",0,1,3,5,5,3,3,["soup","light"]],
["carpaccio","生牛肉薄片","youshoku",0,1,3,5,5,4,2,["meat","raw","light"]],
["croquettes","可乐饼","youshoku",0,1,3,5,3,3,4,["meat","fried"]],
["onion_soup","洋葱汤","youshoku",0,1,3,6,4,3,5,["soup","rich"]],
// YOUSHOKU T1
["gratin","焗烤","youshoku",1,2,6,10,6,5,7,["rich","grilled"]],
["coq_au_vin","红酒炖鸡","youshoku",1,2,6,11,5,6,8,["meat","stewed","rich"]],
["nicoise_salad","尼斯沙拉","youshoku",1,1,5,7,8,5,4,["seafood","light"]],
["risotto","意式烩饭","youshoku",1,2,6,10,5,7,7,["rice","rich","umami_tag"]],
["terrine","法式冻糕","youshoku",1,1,5,7,9,6,4,["meat","mastered"]],
["escargot","法式蜗牛","youshoku",1,1,5,7,6,5,7,["rich"]],
["pasta_carbonara","培根蛋面","youshoku",1,2,6,10,5,6,6,["noodle","egg","rich"]],
["chicken_fricassee","白汁炖鸡","youshoku",1,2,6,9,6,6,7,["meat","stewed","rich"]],
// YOUSHOKU T2
["beef_wellington","惠灵顿牛排","youshoku",2,3,9,18,12,14,10,["meat","rich","mastered"]],
["bouillabaisse","马赛鱼汤","youshoku",2,2,7,14,8,8,12,["seafood","stewed","rich","umami_tag","soup"]],
["duck_confit","油封鸭","youshoku",2,2,7,15,8,10,10,["meat","rich"]],
["lobster_thermidor","焗龙虾","youshoku",2,2,7,16,12,8,8,["seafood","grilled","rich"]],
["souffle","舒芙蕾","youshoku",2,1,5,10,12,10,4,["egg","mastered"]],
["rack_of_lamb","烤羊排","youshoku",2,2,7,15,10,10,9,["meat","grilled","rich","mastered"]],
["steak_frites","牛排薯条","youshoku",2,2,7,14,8,8,8,["meat","grilled","fried","rich"]],
["afternoon_tea","下午茶套装","youshoku",2,2,7,10,14,8,6,["sweet","tea","mastered"]],
["osso_buco","炖小牛胫","youshoku",2,2,7,16,7,9,11,["meat","stewed","rich","umami_tag"]],
// YOUSHOKU T3
["foie_gras","松露鹅肝","youshoku",3,2,9,22,16,12,14,["meat","rich","mastered"]],
["full_course_fr","法式全席","youshoku",3,3,12,20,20,16,12,["mastered","rich"]],
["grand_dessert","大甜品盘","youshoku",3,3,12,18,22,14,8,["sweet","mastered"]],
["chateaubriand","罗西尼牛排","youshoku",3,3,12,24,14,16,12,["meat","rich","mastered"]],
// KANMI T0
["dango","团子","kanmi",0,1,3,4,4,2,2,["sweet","light"]],
["dorayaki","铜锣烧","kanmi",0,1,3,5,3,2,3,["sweet"]],
["daifuku","大福","kanmi",0,1,3,4,5,3,2,["sweet","light"]],
["mochi","年糕","kanmi",0,1,3,3,3,3,2,["sweet","light"]],
["taiyaki","鲷鱼烧","kanmi",0,1,3,5,4,2,3,["sweet","fried"]],
["anmitsu","蜜豆","kanmi",0,1,3,4,4,2,2,["sweet","light"]],
["yokan","羊羹","kanmi",0,1,3,4,5,3,2,["sweet","light","tea"]],
["warabi_mochi","蕨饼","kanmi",0,1,3,4,3,2,2,["sweet","light"]],
// KANMI T1
["matcha_parfait","抹茶芭菲","kanmi",1,2,6,8,10,5,4,["sweet","tea","light"]],
["castella","长崎蛋糕","kanmi",1,1,5,7,5,5,5,["sweet","rich"]],
["sakura_mochi","樱饼","kanmi",1,1,5,6,8,4,5,["sweet","seasonal","light"]],
["mille_crepe","千层蛋糕","kanmi",1,2,6,8,8,7,4,["sweet","mastered"]],
["tsukimi_dango","赏月团子","kanmi",1,1,5,6,7,3,3,["sweet","seasonal","light"]],
["purin","布丁","kanmi",1,1,5,6,6,4,3,["sweet","egg","rich"]],
["crepe","可丽饼","kanmi",1,1,5,6,7,3,3,["sweet"]],
["doll_cookie","人偶饼干","kanmi",1,1,5,5,8,5,3,["sweet","mastered"]],
["chestnut_kinton","栗金团","kanmi",1,1,5,7,6,5,4,["sweet","seasonal"]],
// KANMI T2
["wagashi_assort","上生菓子拼盘","kanmi",2,2,7,12,16,10,4,["sweet","seasonal","mastered","light"]],
["opera_cake","歌剧院蛋糕","kanmi",2,2,7,14,12,8,6,["sweet","rich","mastered"]],
["creme_brulee","焦糖布丁","kanmi",2,1,5,10,10,8,5,["sweet","rich"]],
["moon_cake","月兔月饼","kanmi",2,2,7,12,10,10,8,["sweet","seasonal","mastered"]],
["strawberry_cake","草莓蛋糕","kanmi",2,2,7,11,12,7,5,["sweet","light"]],
["mont_blanc","蒙布朗","kanmi",2,2,7,12,12,9,5,["sweet","mastered","seasonal"]],
["fruit_tart","水果挞","kanmi",2,2,7,11,13,8,4,["sweet","mastered"]],
["tiramisu","提拉米苏","kanmi",2,2,7,13,10,7,7,["sweet","rich"]],
["macaron_tower","马卡龙塔","kanmi",2,2,7,10,15,10,4,["sweet","mastered"]],
// KANMI T3
["piece_montee","糖艺塔","kanmi",3,3,12,16,24,16,6,["sweet","mastered"]],
["phantasm_parfait","幻想乡芭菲","kanmi",3,3,12,18,18,12,10,["sweet","mastered","light"]],
["hourai_sweet","蓬莱药膳甜点","kanmi",3,2,9,16,14,14,12,["sweet","mastered"]],
["time_crystal","时之结晶","kanmi",3,2,9,15,20,15,8,["sweet","mastered"]],
["alice_doll_cake","人偶之梦","kanmi",3,3,12,14,22,18,6,["sweet","mastered"]],
// YATAI T0
["yakitori_y","烤鸡串y","yatai",0,1,2.5,5,2,2,5,["meat","grilled"]],
["yaki_corn","烤玉米","yatai",0,1,3,4,2,1,5,["vegetable","grilled"]],
["takoyaki_y","章鱼烧y","yatai",0,1,3,5,3,3,4,["seafood","fried"]],
["ikayaki","烤鱿鱼","yatai",0,1,3,5,2,2,6,["seafood","grilled"]],
["yaki_imo","烤红薯","yatai",0,1,3,5,1,1,4,["vegetable","grilled","sweet"]],
["hashimaki","筷卷","yatai",0,1,2.5,4,2,1,4,["fried"]],
["yaki_onigiri","烤饭团","yatai",0,1,3,5,2,2,5,["rice","grilled"]],
["taiyaki_y","鲷鱼烧y","yatai",0,1,3,5,3,2,4,["sweet","fried"]],
// YATAI T1
["yatai_ramen","屋台拉面","yatai",1,2,6,10,3,5,9,["noodle","rich","umami_tag"]],
["kushikatsu","炸串","yatai",1,1,5,8,3,4,7,["meat","fried"]],
["okonomiyaki","大阪烧","yatai",1,2,6,9,4,5,8,["seafood","fried","rich"]],
["grilled_lamprey","烤八目鳗","yatai",1,1,5,9,4,5,9,["seafood","grilled","rich"]],
["teppan_yasai","铁板烤蔬菜","yatai",1,1,5,6,4,3,5,["vegetable","grilled","light"]],
["monjayaki","文字烧","yatai",1,1,5,7,2,4,6,["fried","seafood"]],
["karaage","炸鸡","yatai",1,1,5,8,3,3,7,["meat","fried"]],
["yakisoba","日式炒面","yatai",1,1,5,7,3,3,7,["noodle","stir_fried"]],
["negima","葱鸡串","yatai",1,1,5,7,3,3,8,["meat","grilled"]],
// YATAI T2
["motsunabe","内脏锅","yatai",2,3,9,15,4,6,14,["meat","stewed","rich","umami_tag"]],
["robatayaki","炉端烧拼盘","yatai",2,2,7,14,6,6,13,["seafood","grilled","mastered"]],
["jingisukan","成吉思汗烤肉","yatai",2,2,7,14,4,5,12,["meat","grilled"]],
["kinoko_hoiru","锡纸烤蘑菇","yatai",2,1,5,10,4,4,10,["vegetable","grilled","umami_tag"]],
["wagyu_steak","和牛牛排","yatai",2,2,7,16,8,8,10,["meat","grilled","rich","mastered"]],
["hiroshima_yaki","广岛烧","yatai",2,2,7,13,5,7,11,["noodle","fried","rich"]],
["horumon_yaki","烤内脏","yatai",2,1,5,11,2,5,12,["meat","grilled","rich"]],
["tsukune","鸡肉丸串","yatai",2,1,5,12,5,6,11,["meat","grilled"]],
["sanma","盐烤秋刀鱼","yatai",2,2,7,13,6,7,14,["seafood","grilled","light"]],
// YATAI T3
["sparrow_feast","夜雀之宴","yatai",3,3,12,22,8,10,20,["seafood","grilled","mastered"]],
["teppanyaki_course","铁板烧全席","yatai",3,3,12,20,10,12,18,["meat","seafood","grilled","rich","mastered"]],
["magma_grill","岩浆烧烤","yatai",3,3,12,24,4,8,22,["meat","grilled","rich"]],
["phoenix_skewer","不死鸟之串","yatai",3,2,9,18,7,9,19,["meat","grilled","mastered"]],
["mystia_grill","米斯蒂娅秘传","yatai",3,3,12,21,9,11,21,["seafood","grilled","mastered","umami_tag"]],
["meiling_wok","美铃火焰锅","yatai",3,3,12,23,8,12,19,["meat","stir_fried","rich","umami_tag"]],
// YAKUZEN T0
["herbal_tea","草药茶","yakuzen",0,1,3,3,3,2,5,["tea","light"]],
["nanakusa","七草粥","yakuzen",0,1,3,4,3,2,4,["rice","light","seasonal"]],
["ginger_soup","姜汤","yakuzen",0,1,3,4,1,2,6,["soup","light","spicy"]],
["mushroom_tea","蘑菇茶","yakuzen",0,1,3,4,2,2,5,["tea","umami_tag"]],
["kuzu_yu","葛汤","yakuzen",0,1,3,3,2,2,4,["light","soup"]],
["amazake_latte","甘酒拿铁","yakuzen",0,1,3,4,3,2,4,["sweet","fermented","light"]],
["ninjin_shiri","金平胡萝卜","yakuzen",0,1,3,3,3,2,3,["vegetable","light"]],
["chrysanthemum_tea","菊花茶","yakuzen",0,1,3,3,4,2,5,["tea","light"]],
// YAKUZEN T1
["yakuzen_nabe","药膳火锅","yakuzen",1,2,6,8,4,5,9,["stewed","rich","umami_tag"]],
["magic_mushroom_soup","魔法蘑菇汤","yakuzen",1,1,5,7,3,4,8,["soup","umami_tag"]],
["samgyetang","参鸡汤","yakuzen",1,2,6,9,4,5,9,["meat","stewed","rich","umami_tag","soup"]],
["shrine_amazake","神社甘酒","yakuzen",1,1,5,6,4,3,6,["sweet","fermented","light"]],
["reishi_congee","灵芝粥","yakuzen",1,1,5,6,3,4,7,["rice","light","umami_tag"]],
["tonic_soup","药膳补汤","yakuzen",1,1,5,6,3,5,8,["soup","umami_tag","light"]],
["lotus_root_soup","莲藕汤","yakuzen",1,2,6,7,5,4,7,["soup","vegetable","light"]],
["goji_congee","枸杞粥","yakuzen",1,1,5,5,4,3,6,["rice","light"]],
["cordyceps_broth","虫草清汤","yakuzen",1,1,5,7,4,6,8,["soup","umami_tag"]],
// YAKUZEN T2
["eirin_elixir","永琳秘药","yakuzen",2,1,6,8,6,10,10,["mastered"]],
["five_element_soup","五行汤","yakuzen",2,2,7,12,8,10,10,["soup","mastered","umami_tag"]],
["master_spark_brew","魔炮煎药","yakuzen",2,2,6,14,4,8,12,["mastered"]],
["yin_yang_tea","阴阳玉茶","yakuzen",2,1,5,8,8,6,8,["tea","mastered","light"]],
["immortal_peach","仙桃","yakuzen",2,1,6,10,8,6,8,["sweet","mastered"]],
["matcha_medicine","抹茶药茶","yakuzen",2,1,5,8,7,6,8,["tea","light","mastered"]],
["black_sesame","黑芝麻糊","yakuzen",2,1,5.5,9,4,5,9,["sweet","rich","umami_tag"]],
["moon_rabbit_mochi","月兔麻糬","yakuzen",2,1,5,9,7,6,7,["sweet","mastered"]],
["bamboo_elixir","竹笋灵药","yakuzen",2,1,6,10,6,8,9,["vegetable","mastered"]],
// YAKUZEN T3
["hourai_elixir","蓬莱之药","yakuzen",3,2,10,18,12,16,16,["mastered"]],
["hakurei_feast","博丽之宴","yakuzen",3,3,12,16,12,12,16,["mastered","light"]],
["philosopher_stone","贤者之石膳","yakuzen",3,3,11,20,10,14,18,["mastered"]],
["lunar_banquet","月都盛宴","yakuzen",3,3,12,22,14,16,18,["mastered","umami_tag"]],
];

// ---- Parse dishes ----
const DISHES = RAW_DISHES.map(d => ({
  id:d[0], name:d[1], cuisine:d[2], tier:d[3], size:d[4], cd:d[5],
  flavor:d[6], pres:d[7], tech:d[8], aroma:d[9], tags:d[10],
  hasTag(t){ return this.tags.includes(t); }
}));
const DISH_MAP = {};
DISHES.forEach(d => DISH_MAP[d.id] = d);

// ---- JUDGES ----
const JUDGES = {
  yuyuko:   {name:"幽幽子", gluttony:1.8, satietyCap:150, needSensitivity:{addiction:2.0,thirst:0.3,greasy:0.3}, prefTags:["umami_tag","rich"], hateTags:["light"], flavorMult:1.2},
  eiki:     {name:"映姬",   gluttony:0.5, satietyCap:100, needSensitivity:{}, prefTags:[], hateTags:[], flavorMult:1.0, needRewardMult:1.8},
  aya:      {name:"文",     gluttony:0.7, satietyCap:100, needSensitivity:{novelty:2.5}, prefTags:["seasonal","raw"], hateTags:[], flavorMult:0.9, repeatPenalty:2.5},
  yukari:   {name:"紫",     gluttony:1.0, satietyCap:100, needSensitivity:{}, prefTags:["mastered"], hateTags:[], flavorMult:1.0, ignoreSmallFirst:3},
  remilia:  {name:"蕾米莉亚",gluttony:0.6, satietyCap:100, needSensitivity:{}, prefTags:["rich","mastered"], hateTags:["light"], flavorMult:1.1},
  raiko:    {name:"雷鼓",   gluttony:1.2, satietyCap:100, needSensitivity:{}, prefTags:["grilled"], hateTags:[], flavorMult:1.0, rhythmBonus:true},
  tenshi:   {name:"天子",   gluttony:1.0, satietyCap:100, needSensitivity:{}, prefTags:["rich"], hateTags:[], flavorMult:1.0, unmetPenaltyMult:2.5},
  iku:      {name:"衣玖",   gluttony:0.8, satietyCap:100, needSensitivity:{}, prefTags:["light"], hateTags:[], flavorMult:1.0, needDurationBonus:2, cuisineDiversityBonus:0.08},
  miko:     {name:"神子",   gluttony:1.0, satietyCap:100, needSensitivity:{}, prefTags:["mastered"], hateTags:[], flavorMult:1.0, cuisineDiversityBonus:0.05},
  kokoro:   {name:"心",     gluttony:1.0, satietyCap:100, needSensitivity:{addiction:2.0}, prefTags:["sweet"], hateTags:[], flavorMult:1.0, moodSwingMult:3.0},
  yuuka:    {name:"幽香",   gluttony:0.8, satietyCap:100, needSensitivity:{}, prefTags:["vegetable","light","tea"], hateTags:["fried"], flavorMult:1.0, afterglowDurationMult:3},
  yuuma:    {name:"饕餮",   gluttony:2.0, satietyCap:200, needSensitivity:{greasy:0,thirst:0}, prefTags:["rich","meat","fried"], hateTags:["light"], flavorMult:1.3},
};

// ---- NEED SYSTEM ----
const THIRST_TRIGGERS = new Set(["spicy","grilled","roasted","numbing"]);
const THIRST_SATISFIERS = new Set(["soup","tea","light"]);
const GREASY_TRIGGERS = new Set(["rich","fried"]);
const GREASY_SATISFIERS = new Set(["light","sour","tea","vegetable"]);
const STAPLE_SATISFIERS = new Set(["noodle","rice","staple"]);
const SWEET_STOMACH_TAGS = new Set(["sweet"]);

// ---- SIMULATION ENGINE ----

function createJudgeState(judgeId) {
  const j = JUDGES[judgeId] || JUDGES.eiki;
  return {
    judge: j, judgeId,
    satiety: 0,
    mood: 0,
    tasteThreshold: {},  // tag -> count of same flavor type
    needs: [],           // [{type, ttl, source}]
    cuisinesSeen: new Set(),
    dishCount: 0,
    smallDishCount: 0,   // for yukari
    consecutiveFlavor: {tag:null, count:0}, // for addiction
    lastDishScore: 0,
  };
}

function getThresholdDecay(count) {
  // gentler diminishing: 1.0, 0.92, 0.84, 0.76, 0.68, 0.60 ...
  // at count >= 8 (addiction break): reversal 1.2, 1.3, 1.4 ...
  if (count >= 8) return 1.0 + (count - 7) * 0.1; // addiction reversal
  return Math.max(0.5, 1.0 - count * 0.08);
}

function hasNeed(state, type) {
  return state.needs.some(n => n.type === type);
}

function satisfyNeed(state, type) {
  const idx = state.needs.findIndex(n => n.type === type);
  if (idx >= 0) { state.needs.splice(idx, 1); return true; }
  return false;
}

function addNeed(state, type, ttl) {
  const dur = ttl + (state.judge.needDurationBonus || 0);
  if (!hasNeed(state, type)) {
    state.needs.push({type, ttl: dur});
  }
}

function tickNeeds(state) {
  // decrement TTL, remove expired
  state.needs = state.needs.filter(n => { n.ttl--; return n.ttl > 0; });
}

function scoreDish(dish, state, playerQueue, dishIndex) {
  const j = state.judge;
  // base flavor with technique quality multiplier (flattened)
  const techMult = 0.85 + dish.tech / 40; // range 0.875 ~ 1.3 (was /20, too swingy)
  let score = dish.flavor * techMult;

  // ---- size scaling: diminish large dish raw advantage ----
  // large dishes get sqrt scaling to prevent pure stat domination
  if (dish.size >= 2) {
    const sizeNorm = Math.sqrt(dish.size); // 1.41 for size2, 1.73 for size3
    score = score / sizeNorm * 1.2; // partial compensation
  }

  // ---- taste threshold (freshness) ----
  // find dominant flavor tags for this dish
  const flavorTags = dish.tags.filter(t =>
    ["spicy","sweet","rich","umami_tag","sour","light","grilled","fried","stewed","raw","steamed"].includes(t)
  );
  let thresholdMult = 1.0;
  for (const ft of flavorTags) {
    const count = state.tasteThreshold[ft] || 0;
    thresholdMult *= getThresholdDecay(count);
  }
  score *= thresholdMult;

  // ---- need satisfaction bonus ----
  let needBonus = 0;
  let needsMetCount = 0;
  const rewardMult = j.needRewardMult || 1.0;

  // thirst
  if (hasNeed(state, "thirst") && dish.tags.some(t => THIRST_SATISFIERS.has(t))) {
    needBonus += 0.5 * rewardMult;
    satisfyNeed(state, "thirst");
    needsMetCount++;
  }
  // greasy relief
  if (hasNeed(state, "greasy") && dish.tags.some(t => GREASY_SATISFIERS.has(t))) {
    needBonus += 0.4 * rewardMult;
    satisfyNeed(state, "greasy");
    needsMetCount++;
  }
  // want staple
  if (hasNeed(state, "want_staple") && dish.tags.some(t => STAPLE_SATISFIERS.has(t))) {
    needBonus += 0.35 * rewardMult;
    satisfyNeed(state, "want_staple");
    needsMetCount++;
  }
  // sweet stomach
  if (hasNeed(state, "sweet_stomach") && dish.tags.includes("sweet")) {
    needBonus += 0.5 * rewardMult;
    satisfyNeed(state, "sweet_stomach");
    needsMetCount++;
  }
  // novelty
  if (hasNeed(state, "novelty") && !state.cuisinesSeen.has(dish.cuisine)) {
    needBonus += 0.35 * rewardMult;
    satisfyNeed(state, "novelty");
    needsMetCount++;
  }
  // afterglow (previous dish was amazing)
  if (hasNeed(state, "afterglow")) {
    needBonus += 0.25 * rewardMult;
    satisfyNeed(state, "afterglow");
    needsMetCount++;
  }
  // addiction
  if (hasNeed(state, "addiction")) {
    const addTag = state.consecutiveFlavor.tag;
    if (addTag && dish.tags.includes(addTag)) {
      needBonus += 0.6 * rewardMult;
      satisfyNeed(state, "addiction");
      needsMetCount++;
    }
  }

  // Apply need bonus as FLAT addition with diminishing returns
  // Each subsequent need satisfaction in the match gives less bonus
  const totalMetSoFar = state._totalNeedsMet || 0;
  const diminish = Math.max(0.3, 1.0 - totalMetSoFar * 0.08); // 1.0, 0.92, 0.84, ...
  const flatNeedBonus = needBonus * 8 * diminish;
  score += flatNeedBonus;
  state._totalNeedsMet = totalMetSoFar + needsMetCount;

  // ---- utility dish bonus: low-flavor dishes that satisfy needs get a floor ----
  if (needsMetCount > 0 && dish.flavor <= 6) {
    score = Math.max(score, 4 + needsMetCount * 3); // minimum score for useful utility dishes
  }

  // ---- unmet needs penalty ----
  const unmetCount = state.needs.length - needsMetCount; // remaining after satisfaction
  // actually recalc: needs already modified above
  const unmetPenaltyMult = j.unmetPenaltyMult || 1.0;
  if (state.needs.length > 0) {
    score *= Math.max(0.4, 1.0 - state.needs.length * 0.12 * unmetPenaltyMult);
  }

  // ---- mood modifier ----
  const moodMod = 1.0 + state.mood * 0.05; // mood range -5~+5 → 0.75~1.25
  score *= Math.max(0.5, moodMod);

  // ---- judge preference ----
  let prefBonus = 0;
  for (const pt of j.prefTags) {
    if (dish.tags.includes(pt)) prefBonus += 0.1;
  }
  for (const ht of j.hateTags) {
    if (dish.tags.includes(ht)) prefBonus -= 0.15;
  }
  score *= (1 + prefBonus);

  // ---- yukari: ignore first 3 small dishes ----
  if (j.ignoreSmallFirst && dish.size === 1 && state.smallDishCount < j.ignoreSmallFirst) {
    score *= 0.1;
  }

  // ---- aya: repeat cuisine penalty ----
  if (j.repeatPenalty && state.cuisinesSeen.has(dish.cuisine)) {
    score *= (1.0 / j.repeatPenalty); // 0.5 for aya
  }

  // ---- cuisine diversity bonus (iku, miko) ----
  if (j.cuisineDiversityBonus) {
    score *= (1 + state.cuisinesSeen.size * j.cuisineDiversityBonus);
  }

  // ---- presentation as surprise bonus (diminished) ----
  const surpriseThreshold = 8 + state.dishCount * 1.0; // was 0.5, now harder to surprise
  if (dish.pres > surpriseThreshold) {
    score *= 1.0 + (dish.pres - surpriseThreshold) * 0.02; // was 0.03
  }

  // ---- satiety penalty (soft curve) ----
  const satPct = state.satiety / j.satietyCap;
  if (satPct > 0.7) {
    // soft diminishing: at 70% → ×0.9, at 90% → ×0.5, at 100% → ×0.3
    const overPct = (satPct - 0.7) / 0.3; // 0~1
    const satMult = 0.9 - overPct * 0.6;
    // sweet stomach bypasses partially
    if (dish.tags.includes("sweet") && hasNeed(state, "sweet_stomach")) {
      score *= Math.max(0.7, satMult);
    } else {
      score *= Math.max(0.2, satMult);
    }
  }

  // ---- cuisine purity bonus: reward committing to a cuisine ----
  if (state._cuisineCount) {
    state._cuisineCount[dish.cuisine] = (state._cuisineCount[dish.cuisine] || 0) + 1;
    const count = state._cuisineCount[dish.cuisine];
    if (count >= 3) {
      score *= 1.0 + (count - 2) * 0.06; // 3rd dish: +6%, 4th: +12%, 5th: +18%
    }
  } else {
    state._cuisineCount = {[dish.cuisine]: 1};
  }

  // ---- char aroma: consecutive grilled dishes build smoky flavor ----
  if (dish.tags.includes("grilled")) {
    state._grillStreak = (state._grillStreak || 0) + 1;
    if (state._grillStreak >= 2) {
      score *= 1.0 + (state._grillStreak - 1) * 0.1; // 2nd: +10%, 3rd: +20%
    }
  } else {
    state._grillStreak = 0;
  }

  // ---- spicy escalation: consecutive spicy dishes build heat ----
  if (dish.tags.includes("spicy")) {
    state._spicyStreak = (state._spicyStreak || 0) + 1;
    if (state._spicyStreak >= 2) {
      score *= 1.0 + (state._spicyStreak - 1) * 0.08; // 2nd: +8%, 3rd: +16%
    }
  } else {
    state._spicyStreak = 0;
  }

  // ---- predictability penalty: if pattern is too regular, judge gets bored ----
  // Track size pattern: if alternating perfectly (1,2,1,2 or 1,3,1,3), penalize
  if (state._sizeHistory) {
    state._sizeHistory.push(dish.size);
    if (state._sizeHistory.length >= 4) {
      const h = state._sizeHistory;
      const len = h.length;
      // check if last 4 form a perfect alternation
      if (h[len-1] === h[len-3] && h[len-2] === h[len-4] && h[len-1] !== h[len-2]) {
        state._predictCount = (state._predictCount || 0) + 1;
        if (state._predictCount >= 2) {
          score *= Math.max(0.65, 1.0 - state._predictCount * 0.1);
        }
      } else {
        state._predictCount = Math.max(0, (state._predictCount || 0) - 1);
      }
    }
  } else {
    state._sizeHistory = [dish.size];
  }
  if (j.rhythmBonus && needsMetCount > 0) {
    // each need met reduces next dish cd conceptually; we model as score bonus
    score *= (1 + needsMetCount * 0.08);
  }

  return Math.max(0, Math.round(score * 10) / 10);
}

// ---- POST-SERVE STATE UPDATE ----
function postServe(dish, dishScore, state) {
  const j = state.judge;
  state.dishCount++;
  if (dish.size === 1) state.smallDishCount++;
  state.cuisinesSeen.add(dish.cuisine);

  // ---- conditional satiety ----
  const baseSat = [0, 5, 12, 20][dish.size] || 5;
  const avgExpected = 8 + state.dishCount * 1.5; // rough baseline
  let tastiness = dishScore / Math.max(1, avgExpected);
  tastiness = Math.min(tastiness, 2.5); // cap
  let satGain = baseSat * (tastiness < 0.5 ? 0.3 : tastiness < 1.0 ? 0.7 : tastiness < 1.5 ? 1.2 : 1.8);
  // judge gluttony
  satGain *= j.gluttony;
  // preference match → eats more
  if (j.prefTags.some(t => dish.tags.includes(t))) satGain *= 1.3;
  state.satiety = Math.min(state.satiety + satGain, j.satietyCap);

  // ---- taste threshold update ----
  const flavorTags = dish.tags.filter(t =>
    ["spicy","sweet","rich","umami_tag","sour","grilled","fried","stewed","raw","steamed","light"].includes(t)
  );
  for (const ft of flavorTags) {
    state.tasteThreshold[ft] = (state.tasteThreshold[ft] || 0) + 1;
  }
  // light/tea dishes reduce thresholds (yakuzen bonus: double cleanse)
  if (dish.tags.includes("light") || dish.tags.includes("tea")) {
    const cleanseStr = dish.cuisine === "yakuzen" ? 1.5 : 0.5;
    for (const k of Object.keys(state.tasteThreshold)) {
      if (k !== "light" && k !== "tea") {
        state.tasteThreshold[k] = Math.max(0, state.tasteThreshold[k] - cleanseStr);
      }
    }
  }

  // ---- generate needs ----
  // thirst
  if (dish.tags.some(t => THIRST_TRIGGERS.has(t))) {
    const sens = j.needSensitivity.thirst !== undefined ? j.needSensitivity.thirst : 1.0;
    if (sens > 0) addNeed(state, "thirst", Math.ceil(2 * sens));
  }
  // greasy
  if (dish.tags.some(t => GREASY_TRIGGERS.has(t))) {
    const sens = j.needSensitivity.greasy !== undefined ? j.needSensitivity.greasy : 1.0;
    if (sens > 0) addNeed(state, "greasy", Math.ceil(2 * sens));
  }
  // want staple (3 consecutive small non-staple)
  if (dish.size === 1 && !dish.tags.some(t => STAPLE_SATISFIERS.has(t))) {
    state._smallStreak = (state._smallStreak || 0) + 1;
    if (state._smallStreak >= 3) addNeed(state, "want_staple", 3);
  } else {
    state._smallStreak = 0;
  }
  // sweet stomach
  if (state.satiety / j.satietyCap > 0.5 && dish.tags.includes("rich")) {
    addNeed(state, "sweet_stomach", 4);
  }
  // novelty
  if (dish.cuisine !== state._lastCuisine) {
    const sens = j.needSensitivity.novelty || 1.0;
    if (sens > 0.5) addNeed(state, "novelty", Math.ceil(2 * sens));
  }
  state._lastCuisine = dish.cuisine;
  // afterglow (amazing dish)
  if (dishScore > avgExpected * 1.5) {
    const durMult = j.afterglowDurationMult || 1;
    addNeed(state, "afterglow", 1 * durMult);
  }
  // addiction tracking
  const dominantFlavor = flavorTags.find(t => !["light","steamed"].includes(t));
  if (dominantFlavor && dominantFlavor === state.consecutiveFlavor.tag) {
    state.consecutiveFlavor.count++;
    const addSens = j.needSensitivity.addiction || 1.0;
    const threshold = Math.max(1, Math.round(3 / addSens));
    if (state.consecutiveFlavor.count >= threshold) {
      addNeed(state, "addiction", 2);
    }
  } else if (dominantFlavor) {
    state.consecutiveFlavor = {tag: dominantFlavor, count: 1};
  }

  // ---- mood update ----
  if (j.prefTags.some(t => dish.tags.includes(t))) {
    const swing = j.moodSwingMult || 1;
    state.mood = Math.min(5, state.mood + 1 * swing);
  }
  if (j.hateTags.some(t => dish.tags.includes(t))) {
    const swing = j.moodSwingMult || 1;
    state.mood = Math.max(-5, state.mood - 1 * swing);
  }

  // tick needs (age by 1)
  tickNeeds(state);

  state.lastDishScore = dishScore;
}

// ---- SHOWDOWN SIMULATION ----
const SHOWDOWN_DURATION = 30.0;

function simulateShowdown(queueA, queueB, judgeId, rngSeed) {
  const state = createJudgeState(judgeId);
  let timeA = 0, timeB = 0;
  let idxA = 0, idxB = 0;
  let scoreA = 0, scoreB = 0;
  const timeline = [];

  while ((idxA < queueA.length || idxB < queueB.length) &&
         (timeA < SHOWDOWN_DURATION || timeB < SHOWDOWN_DURATION)) {
    const canA = idxA < queueA.length && timeA < SHOWDOWN_DURATION;
    const canB = idxB < queueB.length && timeB < SHOWDOWN_DURATION;
    if (!canA && !canB) break;

    let nextIsA;
    if (!canA) nextIsA = false;
    else if (!canB) nextIsA = true;
    else {
      const finA = timeA + queueA[idxA].cd;
      const finB = timeB + queueB[idxB].cd;
      if (finA < finB) nextIsA = true;
      else if (finB < finA) nextIsA = false;
      else nextIsA = queueA[idxA].aroma >= queueB[idxB].aroma; // tie: aroma
    }

    if (nextIsA) {
      const dish = queueA[idxA];
      timeA += dish.cd;
      if (timeA > SHOWDOWN_DURATION) break;
      const s = scoreDish(dish, state, queueA, idxA);
      scoreA += s;
      postServe(dish, s, state);
      timeline.push({t: timeA, player: "A", dish: dish.id, score: s, satiety: Math.round(state.satiety)});
      idxA++;
    } else {
      const dish = queueB[idxB];
      timeB += dish.cd;
      if (timeB > SHOWDOWN_DURATION) break;
      const s = scoreDish(dish, state, queueB, idxB);
      scoreB += s;
      postServe(dish, s, state);
      timeline.push({t: timeB, player: "B", dish: dish.id, score: s, satiety: Math.round(state.satiety)});
      idxB++;
    }
  }

  return {scoreA, scoreB, winner: scoreA > scoreB ? "A" : scoreB > scoreA ? "B" : "TIE",
          dishesA: idxA, dishesB: idxB, timeline, finalSatiety: Math.round(state.satiety)};
}

// ---- BUILD ARCHETYPES ----
// Each build: {name, description, dishIds (ordered queue)}
// Simulating Day 5-7 level builds (mix of T0-T2, ~7-8 dishes)

const BUILDS = {
  // 1. 速攻小菜流 - all size 1, fast CD, with some need satisfaction
  speed_rush: {
    name: "速攻小菜流",
    desc: "全小菜快速出餐，抢先填满时间轴",
    dishes: ["mapo_tofu","gyoza","yakitori_y","ikayaki","miso_shiru","kung_pao_chicken","karaage","takoyaki_y","negima","yakisoba"]
  },
  // 2. 中华重菜流 - big dishes, high flavor
  chuuka_heavy: {
    name: "中华重菜流",
    desc: "大菜为主，高风味高饱腹",
    dishes: ["wonton_soup","dan_dan_noodles","dongpo_pork","peking_duck","shuizhu_yu","lion_head","mapo_eggplant","congee"]
  },
  // 3. 辛辣连锁流 - spicy chain aiming for addiction
  spicy_chain: {
    name: "辛辣连锁流",
    desc: "连续辣菜冲上瘾，中间插茶清口",
    dishes: ["mapo_tofu","hotpot_base","kung_pao_chicken","dan_dan_noodles","maoxuewang","herbal_tea","shuizhu_yu","ginger_soup","twice_cooked_pork"]
  },
  // 4. 和食清淡流 - light washoku, need chain control
  washoku_light: {
    name: "和食清淡流",
    desc: "清淡和食控制阈值，保持评委新鲜感",
    dishes: ["miso_shiru","tamagoyaki","edamame","chawanmushi","nimono","sashimi","ochazuke","soba_tsuyu","tofu_dengaku"]
  },
  // 5. 西餐精致流 - high presentation, expectation play
  youshoku_elegant: {
    name: "西餐精致流",
    desc: "高卖相西餐，惊喜度路线",
    dishes: ["consomme","caesar_salad","terrine","nicoise_salad","escargot","gratin","pasta_carbonara","souffle"]
  },
  // 6. 甜品专精流 - sweet stomach exploitation
  kanmi_pure: {
    name: "甜品专精流",
    desc: "纯甜品，利用甜品胃独立赛道",
    dishes: ["dango","dorayaki","matcha_parfait","sakura_mochi","mille_crepe","opera_cake","wagashi_assort","creme_brulee","fruit_tart"]
  },
  // 7. 药膳控制流 - soup/tea heavy, need manipulation
  yakuzen_control: {
    name: "药膳控制流",
    desc: "汤茶控制+药膳中菜输出，阈值清洗专家",
    dishes: ["ginger_soup","samgyetang","mushroom_tea","yakuzen_nabe","yin_yang_tea","five_element_soup","master_spark_brew","matcha_medicine","bamboo_elixir"]
  },
  // 8. 烧烤夜市流 - grilled heavy, aroma focused
  yatai_grill: {
    name: "烧烤夜市流",
    desc: "烤物为主，高香气，穿插汤品解渴",
    dishes: ["yakitori_y","ikayaki","miso_shiru","grilled_lamprey","kushikatsu","negima","ginger_soup","robatayaki","wagyu_steak","sanma"]
  },
  // 9. 混搭猎奇流 - max cuisine diversity
  fusion_novelty: {
    name: "混搭猎奇流",
    desc: "6菜系各取1-2道，最大化猎奇需求",
    dishes: ["mapo_tofu","miso_shiru","consomme","dango","yakitori_y","herbal_tea","sashimi","duck_confit","opera_cake"]
  },
  // 10. 鲜味叠加流 - umami stacking
  umami_stack: {
    name: "鲜味叠加流",
    desc: "连续umami菜冲上瘾，高鲜味输出",
    dishes: ["miso_shiru","chawanmushi","nimono","nikujaga","dongpo_pork","unagi","lion_head","five_element_soup"]
  },
  // 11. 节奏交替流 - heavy/light alternating
  rhythm_alt: {
    name: "节奏交替流",
    desc: "重菜轻菜交替，持续满足需求链",
    dishes: ["char_siu","miso_shiru","twice_cooked_pork","herbal_tea","nikujaga","ochazuke","xo_sauce_noodle","tamagoyaki"]
  },
  // 12. 大菜压轴流 - small openers into big finishers
  big_finish: {
    name: "大菜压轴流",
    desc: "中菜开路铺需求，大菜收割",
    dishes: ["miso_shiru","chawanmushi","nimono","ochazuke","nikujaga","dongpo_pork","peking_duck"]
  },
};

// ---- BATCH SIMULATION ----
function runBatch(buildA, buildB, judgeId, n) {
  let winsA = 0, winsB = 0, ties = 0;
  let totalScoreA = 0, totalScoreB = 0;
  for (let i = 0; i < n; i++) {
    const qA = buildA.dishes.map(id => DISH_MAP[id]).filter(Boolean);
    const qB = buildB.dishes.map(id => DISH_MAP[id]).filter(Boolean);
    const result = simulateShowdown(qA, qB, judgeId, i);
    totalScoreA += result.scoreA;
    totalScoreB += result.scoreB;
    if (result.winner === "A") winsA++;
    else if (result.winner === "B") winsB++;
    else ties++;
  }
  return {
    winsA, winsB, ties,
    avgScoreA: Math.round(totalScoreA / n * 10) / 10,
    avgScoreB: Math.round(totalScoreB / n * 10) / 10,
    winRateA: Math.round(winsA / n * 1000) / 10,
  };
}

// ---- MAIN: RUN ALL TESTS ----
function main() {
  const buildNames = Object.keys(BUILDS);
  const judgeIds = Object.keys(JUDGES);

  console.log("=== 东方大巴扎 V2 数值原型模拟 ===\n");

  // Phase 1: Single build strength (vs all others, averaged across judges)
  console.log("--- Phase 1: 各流派综合胜率 ---");
  const overallWinRates = {};
  for (const bName of buildNames) {
    let totalWins = 0, totalGames = 0;
    let totalScore = 0;
    for (const oppName of buildNames) {
      if (oppName === bName) continue;
      for (const jId of judgeIds) {
        const r = runBatch(BUILDS[bName], BUILDS[oppName], jId, 1);
        totalWins += r.winsA;
        totalGames += 1;
        totalScore += r.avgScoreA;
      }
    }
    const wr = Math.round(totalWins / totalGames * 1000) / 10;
    const avgS = Math.round(totalScore / totalGames * 10) / 10;
    overallWinRates[bName] = wr;
    const b = BUILDS[bName];
    console.log(`  ${b.name.padEnd(10)} | 胜率 ${String(wr).padStart(5)}% | 均分 ${String(avgS).padStart(6)} | ${b.desc}`);
  }

  // Phase 2: Build vs Build matrix (using eiki as neutral judge)
  console.log("\n--- Phase 2: 流派对战矩阵 (映姬/中立评委) ---");
  const matrixJudge = "eiki";
  const header = "          " + buildNames.map(n => BUILDS[n].name.slice(0,4).padStart(5)).join("");
  console.log(header);
  for (const bA of buildNames) {
    let row = BUILDS[bA].name.slice(0,8).padEnd(10);
    for (const bB of buildNames) {
      if (bA === bB) { row += "  --- "; continue; }
      const r = runBatch(BUILDS[bA], BUILDS[bB], matrixJudge, 1);
      row += String(r.winRateA > 50 ? "W" : r.winRateA < 50 ? "L" : "T").padStart(5) + " ";
    }
    console.log(row);
  }

  // Phase 3: Judge impact analysis
  console.log("\n--- Phase 3: 评委偏好影响 ---");
  for (const jId of judgeIds) {
    const jName = JUDGES[jId].name;
    let bestBuild = "", bestScore = 0;
    let worstBuild = "", worstScore = Infinity;
    for (const bName of buildNames) {
      let totalScore = 0, count = 0;
      for (const oppName of buildNames) {
        if (oppName === bName) continue;
        const r = runBatch(BUILDS[bName], BUILDS[oppName], jId, 1);
        totalScore += r.avgScoreA;
        count++;
      }
      const avg = totalScore / count;
      if (avg > bestScore) { bestScore = avg; bestBuild = BUILDS[bName].name; }
      if (avg < worstScore) { worstScore = avg; worstBuild = BUILDS[bName].name; }
    }
    console.log(`  ${jName.padEnd(6)} | 最强: ${bestBuild.padEnd(8)} (${Math.round(bestScore)}) | 最弱: ${worstBuild.padEnd(8)} (${Math.round(worstScore)})`);
  }

  // Phase 4: Detailed timeline for one interesting matchup
  console.log("\n--- Phase 4: 示例对局详细时间轴 ---");
  console.log("辛辣连锁 vs 和食清淡 (映姬):");
  const qA = BUILDS.spicy_chain.dishes.map(id => DISH_MAP[id]).filter(Boolean);
  const qB = BUILDS.washoku_light.dishes.map(id => DISH_MAP[id]).filter(Boolean);
  const detail = simulateShowdown(qA, qB, "eiki");
  for (const ev of detail.timeline) {
    console.log(`  T=${String(ev.t).padStart(5)}s | ${ev.player} | ${(DISH_MAP[ev.dish]?.name||ev.dish).padEnd(10)} | 得分 ${String(ev.score).padStart(5)} | 饱腹 ${ev.satiety}`);
  }
  console.log(`  结果: A=${Math.round(detail.scoreA)} B=${Math.round(detail.scoreB)} 胜者=${detail.winner}`);
  console.log(`  A上菜${detail.dishesA}道 B上菜${detail.dishesB}道 最终饱腹${detail.finalSatiety}`);

  // Phase 5: Satiety curve test - does speed rush dominate?
  console.log("\n--- Phase 5: 速攻流统治力测试 ---");
  const speedBuild = BUILDS.speed_rush;
  for (const oppName of buildNames) {
    if (oppName === "speed_rush") continue;
    let wins = 0, total = 0;
    for (const jId of judgeIds) {
      const r = runBatch(speedBuild, BUILDS[oppName], jId, 1);
      wins += r.winsA;
      total++;
    }
    const wr = Math.round(wins / total * 100);
    const flag = wr > 70 ? " ⚠️ 过强" : wr < 30 ? " ✓ 被克制" : "";
    console.log(`  速攻 vs ${BUILDS[oppName].name.padEnd(10)} | 胜率 ${wr}%${flag}`);
  }

  // Phase 6: Addiction reversal test
  console.log("\n--- Phase 6: 上瘾反转测试 ---");
  console.log("辛辣连锁 vs 混搭猎奇 (幽幽子/上瘾敏感):");
  const qSpicy = BUILDS.spicy_chain.dishes.map(id => DISH_MAP[id]).filter(Boolean);
  const qFusion = BUILDS.fusion_novelty.dishes.map(id => DISH_MAP[id]).filter(Boolean);
  const addTest = simulateShowdown(qSpicy, qFusion, "yuyuko");
  for (const ev of addTest.timeline) {
    console.log(`  T=${String(ev.t).padStart(5)}s | ${ev.player} | ${(DISH_MAP[ev.dish]?.name||ev.dish).padEnd(10)} | 得分 ${String(ev.score).padStart(5)} | 饱腹 ${ev.satiety}`);
  }
  console.log(`  结果: A(辛辣)=${Math.round(addTest.scoreA)} B(混搭)=${Math.round(addTest.scoreB)} 胜者=${addTest.winner}`);

  // Summary
  console.log("\n=== 平衡性总结 ===");
  const sorted = buildNames.sort((a,b) => overallWinRates[b] - overallWinRates[a]);
  const top = BUILDS[sorted[0]];
  const bot = BUILDS[sorted[sorted.length-1]];
  const spread = overallWinRates[sorted[0]] - overallWinRates[sorted[sorted.length-1]];
  console.log(`最强流派: ${top.name} (${overallWinRates[sorted[0]]}%)`);
  console.log(`最弱流派: ${bot.name} (${overallWinRates[sorted[sorted.length-1]]}%)`);
  console.log(`胜率极差: ${Math.round(spread*10)/10}%`);
  if (spread > 30) console.log("⚠️ 平衡性差距过大，需要调整");
  else if (spread > 20) console.log("⚠ 有一定差距，可接受但建议微调");
  else console.log("✓ 平衡性在合理范围内");
}

main();
