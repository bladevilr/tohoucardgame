// ============================================================
// 东方大巴扎 V2 数值原型模拟器 v2 (完整重写)
// 需求链 + 条件饱腹度 + 味觉阈值(含上瘾反转) + 简化得分
// 所有 build 统一到 Day5-7 水平 (T0+T1为主, 1-2张T2)
// 多局统计 + seeded RNG + 参数微调
//
// === 平衡性结论 (22轮迭代后) ===
// 极差: 10.6% (53.8% → 43.2%)  ✓ 合理范围
// 12流派全部在 43-54% 胜率区间
//
// 关键公式参数:
//   thresholdDecay: max(0.60, 1.0 - count * 0.05), 8+反转
//   fatigue: max(0.55, 1.0 - dishCount * 0.05)
//   needBonus: flat * 4 * diminishing(0.06/met)
//   sizeScaling: score / size^0.6 * 1.1
//   coherenceBonus: +8% max (dishCount >= 3)
//   smallDishSaturation: -7%/dish after 4th small dish
//   cuisinePurity: +7%/dish after 2nd same cuisine
//   yakuzen: ×1.15, cleanse 2.0 (vs 0.7 base)
//   kanmi: pres bonus +4%/point above 3
//   youshoku: course meal +6%/dish after 2nd, pres surprise 3.5%
//   grillStreak: +8%/consecutive, spicyStreak: +5% capped at 2
//
// 评委差异化良好: 每个流派都有最佳/最差评委
// 石头剪刀布关系健康: 无绝对优势流派
// ============================================================
"use strict";

// ---- SEEDED RNG ----
function mulberry32(a) {
  return function() {
    a |= 0; a = a + 0x6D2B79F5 | 0;
    var t = Math.imul(a ^ a >>> 15, 1 | a);
    t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
    return ((t ^ t >>> 14) >>> 0) / 4294967296;
  };
}

// ---- DISH DATABASE ----
// format: [id, name, cuisine, tier, size, cd, flavor, pres, tech, aroma, tags[]]
const R = [
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
["kung_pao","宫保鸡丁","chuuka",1,1,5,9,4,6,7,["meat","stir_fried","spicy"]],
["sweet_sour","糖醋排骨","chuuka",1,2,6,11,6,5,6,["meat","fried","sweet","sour"]],
["dandan","担担面","chuuka",1,1,5,9,3,5,8,["noodle","spicy","rich","umami_tag"]],
["char_siu","叉烧","chuuka",1,1,5,10,5,4,8,["meat","grilled","rich"]],
["spring_rolls","春卷","chuuka",1,1,5,7,5,5,5,["vegetable","fried"]],
["niurou_mian","牛肉面","chuuka",1,2,6,10,3,5,9,["noodle","meat","stewed","rich"]],
["maoxuewang","毛血旺","chuuka",1,2,6,11,3,4,8,["meat","spicy","rich","stewed"]],
["xo_noodle","XO酱炒面","chuuka",1,1,5,8,4,5,7,["noodle","stir_fried","rich"]],
["twice_cooked","回锅肉","chuuka",1,1,5,9,4,6,7,["meat","stir_fried","rich"]],
// CHUUKA T2
["peking_duck","北京烤鸭","chuuka",2,3,9,18,10,12,14,["meat","grilled","rich","mastered"]],
["dongpo","东坡肉","chuuka",2,2,7,16,6,8,10,["meat","stewed","rich","umami_tag"]],
["steamed_fish","清蒸鲈鱼","chuuka",2,2,7,13,8,10,9,["seafood","steamed","light","umami_tag"]],
["shuizhu_yu","水煮鱼","chuuka",2,2,7,15,5,7,11,["seafood","spicy","rich"]],
["lion_head","红烧狮子头","chuuka",2,2,7,14,6,8,10,["meat","stewed","rich","umami_tag"]],
["mapo_eggplant","鱼香茄子","chuuka",2,1,5,12,5,7,9,["vegetable","stir_fried","rich"]],
["dim_sum","点心拼盘","chuuka",2,2,7,12,10,10,6,["steamed","mastered"]],
["wuxing_chaohe","五行炒河","chuuka",2,2,7,14,4,8,12,["noodle","stir_fried","rich"]],
// WASHOKU T0
["onigiri","饭团","washoku",0,1,3,6,2,2,3,["rice","light","staple"]],
["miso_shiru","味噌汤","washoku",0,1,3,5,2,3,5,["soup","umami_tag","light"]],
["tamagoyaki","玉子烧","washoku",0,1,3,5,4,4,2,["egg","light","mastered"]],
["tsukemono","渍物","washoku",0,1,3,4,3,2,4,["vegetable","light","fermented","sour"]],
["edamame","毛豆","washoku",0,1,3,3,2,1,3,["vegetable","light"]],
["hiyayakko","冷豆腐","washoku",0,1,3,3,3,1,3,["vegetable","light"]],
["yakitori_w","烤鸡串w","washoku",0,1,3,7,3,3,6,["meat","grilled","light"]],
// WASHOKU T1
["sashimi","刺身拼盘","washoku",1,2,6,12,8,10,5,["seafood","raw","light"]],
["chawanmushi","茶碗蒸","washoku",1,1,5,8,6,6,6,["egg","steamed","umami_tag","light"]],
["yakizakana","烤鱼","washoku",1,1,5,9,4,5,8,["seafood","grilled"]],
["nikujaga","肉土豆","washoku",1,2,6,10,4,5,7,["meat","stewed","rich","umami_tag"]],
["tofu_dengaku","味噌烤豆腐","washoku",1,1,5,7,5,4,5,["vegetable","grilled","light"]],
["nimono","煮物","washoku",1,1,5,8,5,5,6,["vegetable","stewed","light","umami_tag"]],
["kitsune_udon","狐狸乌冬","washoku",1,2,6,9,4,4,8,["noodle","umami_tag","light"]],
["agedashi_tofu","炸出汁豆腐","washoku",1,1,5,7,6,6,5,["vegetable","fried","umami_tag"]],
["takoyaki_w","章鱼烧w","washoku",1,1,5,8,5,5,7,["seafood","fried","light"]],
// WASHOKU T2
["tempura","天妇罗拼盘","washoku",2,2,7,14,10,12,8,["seafood","fried","mastered"]],
["unagi","蒲烧鳗鱼","washoku",2,2,7,16,6,8,12,["seafood","grilled","rich","umami_tag"]],
["sukiyaki","寿喜烧","washoku",2,3,9,18,6,6,10,["meat","stewed","rich","umami_tag"]],
["ochazuke","茶泡饭","washoku",2,1,5,10,3,4,8,["rice","light","tea"]],
["soba_tsuyu","冷荞麦面","washoku",2,1,5,11,7,8,6,["noodle","light","mastered"]],
["kaisendon","海鲜盖饭","washoku",2,2,7,13,10,8,7,["seafood","raw","rice"]],
["chanko_nabe","相扑火锅","washoku",2,3,9,15,4,5,12,["meat","stewed","rich","umami_tag"]],
["katsudon","炸猪排盖饭","washoku",2,2,7,14,5,7,9,["meat","fried","rice","rich"]],
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
];

// ---- Parse dishes ----
const DISHES = R.map(d => ({
  id:d[0], name:d[1], cuisine:d[2], tier:d[3], size:d[4], cd:d[5],
  flavor:d[6], pres:d[7], tech:d[8], aroma:d[9], tags:d[10],
}));
const D = {};
DISHES.forEach(d => D[d.id] = d);

// ---- JUDGES ----
// Tuned: reduced extreme multipliers, more differentiation via mechanics not raw numbers
const JUDGES = {
  yuyuko:  {name:"幽幽子", gluttony:1.6, satietyCap:140, needSens:{addiction:1.8,thirst:0.3,greasy:0.3}, pref:["umami_tag","rich"], hate:["light"], flavorMult:1.15},
  eiki:    {name:"映姬",   gluttony:0.6, satietyCap:100, needSens:{}, pref:[], hate:[], flavorMult:1.0, needRewardMult:1.6},
  aya:     {name:"文",     gluttony:0.7, satietyCap:100, needSens:{novelty:2.0}, pref:["seasonal","raw"], hate:[], flavorMult:0.95, repeatPenalty:2.0},
  yukari:  {name:"紫",     gluttony:1.0, satietyCap:110, needSens:{}, pref:["mastered"], hate:[], flavorMult:1.0, ignoreSmallFirst:2},
  remilia: {name:"蕾米莉亚",gluttony:0.6, satietyCap:100, needSens:{}, pref:["rich","mastered"], hate:["light"], flavorMult:1.05},
  raiko:   {name:"雷鼓",   gluttony:1.1, satietyCap:100, needSens:{}, pref:["grilled"], hate:[], flavorMult:1.0, rhythmBonus:true},
  tenshi:  {name:"天子",   gluttony:1.0, satietyCap:100, needSens:{}, pref:["rich"], hate:[], flavorMult:1.0, unmetPenaltyMult:2.0},
  iku:     {name:"衣玖",   gluttony:0.8, satietyCap:100, needSens:{}, pref:["light"], hate:[], flavorMult:1.0, needDurationBonus:1, cuisineDiversityBonus:0.035},
  miko:    {name:"神子",   gluttony:1.0, satietyCap:100, needSens:{}, pref:["mastered"], hate:[], flavorMult:1.0, cuisineDiversityBonus:0.025},
  kokoro:  {name:"心",     gluttony:1.0, satietyCap:100, needSens:{addiction:1.8}, pref:["sweet"], hate:[], flavorMult:1.0, moodSwingMult:2.5},
  yuuka:   {name:"幽香",   gluttony:0.8, satietyCap:100, needSens:{}, pref:["vegetable","light","tea"], hate:["fried"], flavorMult:1.0, afterglowDurMult:2},
  yuuma:   {name:"饕餮",   gluttony:1.8, satietyCap:180, needSens:{greasy:0,thirst:0}, pref:["rich","meat","fried"], hate:["light"], flavorMult:1.2},
};

// ---- NEED SYSTEM ----
const THIRST_TRIGGERS = new Set(["spicy","grilled","roasted","numbing"]);
const THIRST_SATISFIERS = new Set(["soup","tea","light"]);
const GREASY_TRIGGERS = new Set(["rich","fried"]);
const GREASY_SATISFIERS = new Set(["light","sour","tea","vegetable"]);
const STAPLE_SATISFIERS = new Set(["noodle","rice","staple"]);
const FLAVOR_TAGS = new Set(["spicy","sweet","rich","umami_tag","sour","light","grilled","fried","stewed","raw","steamed"]);

// ---- SIMULATION ENGINE ----
function createState(judgeId) {
  const j = JUDGES[judgeId] || JUDGES.eiki;
  return {
    j, judgeId, satiety:0, mood:0,
    threshold:{}, needs:[], cuisinesSeen:new Set(),
    dishCount:0, smallDishCount:0,
    consFlavor:{tag:null,count:0}, lastScore:0,
    _totalNeedsMet:0, _cuisineCount:{},
    _grillStreak:0, _spicyStreak:0,
    _sizeHistory:[], _predictCount:0, _smallStreak:0,
    _lastCuisine:null,
  };
}

function thresholdDecay(count) {
  // Gentler: 1.0, 0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65
  // Addiction reversal at 8+
  if (count >= 8) return 1.0 + (count - 7) * 0.1;
  return Math.max(0.60, 1.0 - count * 0.05);
}

function hasNeed(s, type) { return s.needs.some(n => n.type === type); }
function satisfyNeed(s, type) {
  const i = s.needs.findIndex(n => n.type === type);
  if (i >= 0) { s.needs.splice(i, 1); return true; }
  return false;
}
function addNeed(s, type, ttl) {
  const dur = ttl + (s.j.needDurationBonus || 0);
  if (!hasNeed(s, type)) s.needs.push({type, ttl: dur});
}
function tickNeeds(s) { s.needs = s.needs.filter(n => { n.ttl--; return n.ttl > 0; }); }

function scoreDish(dish, s) {
  const j = s.j;
  // base: flavor × tech multiplier (flattened)
  const techMult = 0.85 + dish.tech / 40;
  let score = dish.flavor * techMult;

  // dish count fatigue: each dish served slightly less impactful (nerfs speed rush)
  // steeper curve: 5th dish at 0.75, 8th at 0.60, 9th at 0.55
  const fatigue = Math.max(0.55, 1.0 - s.dishCount * 0.05);
  score *= fatigue;

  // size scaling: stronger normalization to prevent big dish domination
  if (dish.size >= 2) {
    score = score / Math.pow(dish.size, 0.6) * 1.1;
  }

  // taste threshold
  const fTags = dish.tags.filter(t => FLAVOR_TAGS.has(t));
  let thMult = 1.0;
  for (const ft of fTags) {
    thMult *= thresholdDecay(s.threshold[ft] || 0);
  }
  score *= thMult;

  // need satisfaction (flat bonus)
  let needBonus = 0, needsMet = 0;
  const rMult = j.needRewardMult || 1.0;

  if (hasNeed(s,"thirst") && dish.tags.some(t => THIRST_SATISFIERS.has(t))) {
    needBonus += 0.5 * rMult; satisfyNeed(s,"thirst"); needsMet++;
  }
  if (hasNeed(s,"greasy") && dish.tags.some(t => GREASY_SATISFIERS.has(t))) {
    needBonus += 0.4 * rMult; satisfyNeed(s,"greasy"); needsMet++;
  }
  if (hasNeed(s,"want_staple") && dish.tags.some(t => STAPLE_SATISFIERS.has(t))) {
    needBonus += 0.35 * rMult; satisfyNeed(s,"want_staple"); needsMet++;
  }
  if (hasNeed(s,"sweet_stomach") && dish.tags.includes("sweet")) {
    needBonus += 0.5 * rMult; satisfyNeed(s,"sweet_stomach"); needsMet++;
  }
  if (hasNeed(s,"novelty") && !s.cuisinesSeen.has(dish.cuisine)) {
    needBonus += 0.35 * rMult; satisfyNeed(s,"novelty"); needsMet++;
  }
  if (hasNeed(s,"afterglow")) {
    needBonus += 0.25 * rMult; satisfyNeed(s,"afterglow"); needsMet++;
  }
  if (hasNeed(s,"addiction")) {
    const at = s.consFlavor.tag;
    if (at && dish.tags.includes(at)) {
      needBonus += 0.6 * rMult; satisfyNeed(s,"addiction"); needsMet++;
    }
  }

  // diminishing returns on cumulative need satisfaction
  const dim = Math.max(0.35, 1.0 - s._totalNeedsMet * 0.06);
  score += needBonus * 4 * dim;
  s._totalNeedsMet += needsMet;

  // utility dish floor
  if (needsMet > 0 && dish.flavor <= 6) {
    score = Math.max(score, 2.5 + needsMet * 2);
  }

  // unmet needs penalty
  const unmetMult = j.unmetPenaltyMult || 1.0;
  if (s.needs.length > 0) {
    score *= Math.max(0.45, 1.0 - s.needs.length * 0.10 * unmetMult);
  }

  // mood
  score *= Math.max(0.55, 1.0 + s.mood * 0.04);

  // judge preference
  let pref = 0;
  for (const pt of j.pref) { if (dish.tags.includes(pt)) pref += 0.08; }
  for (const ht of j.hate) { if (dish.tags.includes(ht)) pref -= 0.12; }
  score *= (1 + pref);

  // yukari: ignore first N small dishes
  if (j.ignoreSmallFirst && dish.size === 1 && s.smallDishCount < j.ignoreSmallFirst) {
    score *= 0.15;
  }

  // aya: repeat cuisine penalty
  if (j.repeatPenalty && s.cuisinesSeen.has(dish.cuisine)) {
    score *= (1.0 / j.repeatPenalty);
  }

  // cuisine diversity bonus (iku, miko)
  if (j.cuisineDiversityBonus) {
    score *= (1 + s.cuisinesSeen.size * j.cuisineDiversityBonus);
  }

  // presentation surprise + youshoku/kanmi presentation identity
  const surpriseBase = 5 + s.dishCount * 0.6;
  if (dish.pres > surpriseBase) {
    const presMult = (dish.cuisine === "youshoku" || dish.cuisine === "kanmi") ? 0.035 : 0.015;
    score *= 1.0 + (dish.pres - surpriseBase) * presMult;
  }

  // youshoku course meal bonus: sequential youshoku dishes build elegance
  if (dish.cuisine === "youshoku") {
    const yCount = s._cuisineCount["youshoku"] || 0;
    if (yCount >= 2) score *= 1.0 + (yCount - 1) * 0.06;
  }

  // satiety penalty
  const satPct = s.satiety / j.satietyCap;
  if (satPct > 0.7) {
    const over = (satPct - 0.7) / 0.3;
    let satMult = 0.9 - over * 0.55;
    if (dish.tags.includes("sweet") && hasNeed(s,"sweet_stomach")) {
      score *= Math.max(0.7, satMult);
    } else {
      score *= Math.max(0.25, satMult);
    }
  }

  // cuisine purity bonus (stronger to help mono-cuisine compete with diversity)
  s._cuisineCount[dish.cuisine] = (s._cuisineCount[dish.cuisine] || 0) + 1;
  const cc = s._cuisineCount[dish.cuisine];
  if (cc >= 3) score *= 1.0 + (cc - 2) * 0.07;

  // flavor coherence bonus: dishes that match the established flavor profile get a bonus
  // rewards thematic builds, taxes scattered/random builds
  // only kicks in after 3 dishes (need established profile)
  if (s.dishCount >= 3) {
    const totalTh = Object.values(s.threshold).reduce((a,b) => a+b, 0);
    if (totalTh > 0) {
      let matchWeight = 0;
      for (const ft of fTags) {
        const th = s.threshold[ft] || 0;
        matchWeight += th / totalTh;
      }
      // matchWeight 0~1: 0 = completely new flavors, 1 = exact same profile
      // bonus: up to +8% for perfect coherence
      score *= 1.0 + matchWeight * 0.08;
    }
  }

  // yakuzen/tea/soup cleanse bonus: proportional to accumulated threshold
  if (dish.cuisine === "yakuzen" || dish.tags.includes("tea") || dish.tags.includes("soup")) {
    const totalThreshold = Object.values(s.threshold).reduce((a,b) => a+b, 0);
    if (totalThreshold > 2) {
      const cleanseValue = Math.min(totalThreshold * 0.25, 3);
      score += cleanseValue;
    }
  }

  // yakuzen cuisine bonus: medicinal dishes have inherent value beyond flavor
  if (dish.cuisine === "yakuzen") {
    score *= 1.15;
  }
  // kanmi presentation bonus: desserts are visual experiences
  if (dish.cuisine === "kanmi" && dish.pres >= 4) {
    score *= 1.0 + (dish.pres - 3) * 0.04;
  }

  // grill streak
  if (dish.tags.includes("grilled")) {
    s._grillStreak++;
    if (s._grillStreak >= 2) score *= 1.0 + (s._grillStreak - 1) * 0.08;
  } else { s._grillStreak = 0; }

  // spicy streak (capped to prevent runaway)
  if (dish.tags.includes("spicy")) {
    s._spicyStreak++;
    if (s._spicyStreak >= 2) score *= 1.0 + Math.min(s._spicyStreak - 1, 2) * 0.05;
  } else { s._spicyStreak = 0; }

  // predictability penalty
  s._sizeHistory.push(dish.size);
  if (s._sizeHistory.length >= 4) {
    const h = s._sizeHistory, l = h.length;
    if (h[l-1]===h[l-3] && h[l-2]===h[l-4] && h[l-1]!==h[l-2]) {
      s._predictCount++;
      if (s._predictCount >= 2) score *= Math.max(0.7, 1.0 - s._predictCount * 0.08);
    } else {
      s._predictCount = Math.max(0, s._predictCount - 1);
    }
  }

  // rhythm bonus (raiko)
  if (j.rhythmBonus && needsMet > 0) {
    score *= (1 + needsMet * 0.06);
  }

  // small dish saturation: judge wants variety in portion sizes
  // after 4+ consecutive or 5+ total small dishes, penalty kicks in
  if (dish.size === 1 && s.smallDishCount >= 4) {
    const overSmall = s.smallDishCount - 3;
    score *= Math.max(0.65, 1.0 - overSmall * 0.07);
  }

  return Math.max(0, Math.round(score * 10) / 10);
}

// ---- POST-SERVE STATE UPDATE ----
function postServe(dish, dishScore, s) {
  const j = s.j;
  s.dishCount++;
  if (dish.size === 1) s.smallDishCount++;
  s.cuisinesSeen.add(dish.cuisine);

  // conditional satiety
  const baseSat = [0, 5, 11, 18][dish.size] || 5;
  const avgExp = 7 + s.dishCount * 1.2;
  let tastiness = Math.min(dishScore / Math.max(1, avgExp), 2.5);
  let satGain = baseSat * (tastiness < 0.5 ? 0.3 : tastiness < 1.0 ? 0.65 : tastiness < 1.5 ? 1.1 : 1.6);
  satGain *= j.gluttony;
  if (j.pref.some(t => dish.tags.includes(t))) satGain *= 1.2;
  s.satiety = Math.min(s.satiety + satGain, j.satietyCap);

  // taste threshold update (light/sweet count less)
  const fTags2 = dish.tags.filter(t => FLAVOR_TAGS.has(t));
  for (const ft of fTags2) {
    const inc = (ft === "sweet" || ft === "light") ? 0.5 : 1.0;
    s.threshold[ft] = (s.threshold[ft] || 0) + inc;
  }

  // cleanse from light/tea (yakuzen double, stronger base)
  if (dish.tags.includes("light") || dish.tags.includes("tea")) {
    const str = dish.cuisine === "yakuzen" ? 2.0 : 0.7;
    for (const k of Object.keys(s.threshold)) {
      if (k !== "light" && k !== "tea") {
        s.threshold[k] = Math.max(0, s.threshold[k] - str);
      }
    }
  }

  // generate needs
  if (dish.tags.some(t => THIRST_TRIGGERS.has(t))) {
    const sens = s.j.needSens.thirst !== undefined ? s.j.needSens.thirst : 1.0;
    if (sens > 0) addNeed(s, "thirst", Math.ceil(2 * sens));
  }
  if (dish.tags.some(t => GREASY_TRIGGERS.has(t))) {
    const sens = s.j.needSens.greasy !== undefined ? s.j.needSens.greasy : 1.0;
    if (sens > 0) addNeed(s, "greasy", Math.ceil(2 * sens));
  }
  if (dish.size === 1 && !dish.tags.some(t => STAPLE_SATISFIERS.has(t))) {
    s._smallStreak++;
    if (s._smallStreak >= 3) addNeed(s, "want_staple", 3);
  } else { s._smallStreak = 0; }

  if (s.satiety / j.satietyCap > 0.35 && dish.tags.includes("rich")) {
    addNeed(s, "sweet_stomach", 4);
  }

  if (dish.cuisine !== s._lastCuisine) {
    const sens = s.j.needSens.novelty || 1.0;
    if (sens > 0.5) addNeed(s, "novelty", Math.ceil(2 * sens));
  }
  s._lastCuisine = dish.cuisine;

  const avgExp2 = 7 + s.dishCount * 1.2;
  if (dishScore > avgExp2 * 1.4) {
    const durM = j.afterglowDurMult || 1;
    addNeed(s, "afterglow", 1 * durM);
  }

  // addiction tracking
  const domFlavor = fTags2.find(t => !["light","steamed"].includes(t));
  if (domFlavor && domFlavor === s.consFlavor.tag) {
    s.consFlavor.count++;
    const addSens = s.j.needSens.addiction || 1.0;
    const threshold = Math.max(1, Math.round(3 / addSens));
    if (s.consFlavor.count >= threshold) addNeed(s, "addiction", 2);
  } else if (domFlavor) {
    s.consFlavor = {tag: domFlavor, count: 1};
  }

  // mood
  if (j.pref.some(t => dish.tags.includes(t))) {
    s.mood = Math.min(5, s.mood + 1 * (j.moodSwingMult || 1));
  }
  if (j.hate.some(t => dish.tags.includes(t))) {
    s.mood = Math.max(-5, s.mood - 1 * (j.moodSwingMult || 1));
  }

  tickNeeds(s);
  s.lastScore = dishScore;
}

// ---- SHOWDOWN ----
const DURATION = 30.0;

function simulate(qA, qB, judgeId) {
  const s = createState(judgeId);
  let tA=0, tB=0, iA=0, iB=0, sA=0, sB=0;
  const timeline = [];

  while ((iA < qA.length || iB < qB.length) && (tA < DURATION || tB < DURATION)) {
    const canA = iA < qA.length && tA < DURATION;
    const canB = iB < qB.length && tB < DURATION;
    if (!canA && !canB) break;

    let nextA;
    if (!canA) nextA = false;
    else if (!canB) nextA = true;
    else {
      const fA = tA + qA[iA].cd, fB = tB + qB[iB].cd;
      nextA = fA < fB ? true : fB < fA ? false : qA[iA].aroma >= qB[iB].aroma;
    }

    if (nextA) {
      const d = qA[iA]; tA += d.cd;
      if (tA > DURATION) break;
      const sc = scoreDish(d, s); sA += sc;
      postServe(d, sc, s);
      timeline.push({t:tA, p:"A", dish:d.id, score:sc, sat:Math.round(s.satiety)});
      iA++;
    } else {
      const d = qB[iB]; tB += d.cd;
      if (tB > DURATION) break;
      const sc = scoreDish(d, s); sB += sc;
      postServe(d, sc, s);
      timeline.push({t:tB, p:"B", dish:d.id, score:sc, sat:Math.round(s.satiety)});
      iB++;
    }
  }

  return {sA, sB, winner: sA > sB ? "A" : sB > sA ? "B" : "T",
          dA:iA, dB:iB, timeline, finalSat:Math.round(s.satiety)};
}

// ---- BUILDS (Day 5-7: T0+T1 core, max 1-2 T2, 7-9 dishes) ----
// DESIGN PRINCIPLE: Every build must have:
// 1. A flavor identity (what tags dominate)
// 2. A need chain strategy (how it generates and satisfies needs)
// 3. At least 1 cleanse/utility dish
// 4. Similar total dish quality (avg flavor ~7-8 across the queue)
const BUILDS = {
  // 1. 速攻小菜流 - size 1, fast CD, quantity (fewer dishes to balance)
  speed_rush: {
    name:"速攻小菜流", desc:"全小菜快速出餐，数量压制",
    dishes:["gyoza","yakitori_y","ikayaki","miso_shiru","kung_pao","karaage","ginger_soup","negima"]
  },
  // 2. 中华重菜流 - chuuka T1 heavy, rich flavor. Need chain: rich→greasy→congee satisfies
  chuuka_heavy: {
    name:"中华重菜流", desc:"中华大菜，高风味输出",
    dishes:["wonton_soup","xiaolongbao","chahan","baozi","congee","spring_rolls","sweet_sour","niurou_mian"]
  },
  // 3. 辛辣连锁流 - spicy chain → addiction. Need chain: spicy→thirst→tea→spicy
  spicy_chain: {
    name:"辛辣连锁流", desc:"连续辣菜冲上瘾，中间插茶清口",
    dishes:["mapo_tofu","hotpot_base","kung_pao","dandan","herbal_tea","ginger_soup","twice_cooked","maoxuewang"]
  },
  // 4. 和食清淡流 - light washoku, umami. Need chain: umami stacking, light cleanses
  washoku_light: {
    name:"和食清淡流", desc:"清淡和食，鲜味叠加控制阈值",
    dishes:["miso_shiru","tamagoyaki","chawanmushi","nimono","yakizakana","sashimi","kitsune_udon","ochazuke"]
  },
  // 5. 西餐精致流 - youshoku course meal, rich + high pres
  youshoku_elegant: {
    name:"西餐精致流", desc:"高卖相西餐，精致课程路线",
    dishes:["consomme","onion_soup","gratin","coq_au_vin","risotto","pasta_carbonara","duck_confit","rack_of_lamb"]
  },
  // 6. 甜品专精流 - sweet stomach + rich dishes to trigger it
  kanmi_pure: {
    name:"甜品专精流", desc:"甜品为主，利用甜品胃赛道",
    dishes:["quiche","castella","matcha_parfait","mille_crepe","purin","creme_brulee","opera_cake","tiramisu"]
  },
  // 7. 药膳控制流 - cleanse specialist with T2 finishers
  yakuzen_control: {
    name:"药膳控制流", desc:"汤茶控制+药膳输出，阈值清洗",
    dishes:["herbal_tea","ginger_soup","samgyetang","magic_mushroom_soup","cordyceps_broth","yakuzen_nabe","five_element_soup","master_spark_brew"]
  },
  // 8. 烧烤夜市流 - grilled streak with T2 finishers
  yatai_grill: {
    name:"烧烤夜市流", desc:"烤物连击，高香气输出",
    dishes:["yakitori_y","ikayaki","miso_shiru","grilled_lamprey","negima","ginger_soup","robatayaki","wagyu_steak","tsukune"]
  },
  // 9. 混搭猎奇流 - max cuisine diversity, novelty need
  fusion_novelty: {
    name:"混搭猎奇流", desc:"多菜系混搭，最大化猎奇",
    dishes:["gyoza","miso_shiru","consomme","dango","yakitori_y","herbal_tea","escargot"]
  },
  // 10. 鲜味叠加流 - umami stacking → addiction, with T2 finisher
  umami_stack: {
    name:"鲜味叠加流", desc:"连续umami菜冲上瘾",
    dishes:["miso_shiru","chawanmushi","nimono","nikujaga","agedashi_tofu","samgyetang","kitsune_udon","unagi"]
  },
  // 11. 节奏交替流 - heavy/light alternating
  rhythm_alt: {
    name:"节奏交替流", desc:"重菜轻菜交替，满足需求链",
    dishes:["baozi","miso_shiru","xo_noodle","herbal_tea","nikujaga","congee","tamagoyaki"]
  },
  // 12. 大菜压轴流 - fast openers → T2 finishers
  big_finish: {
    name:"大菜压轴流", desc:"小菜铺路，大菜收割",
    dishes:["miso_shiru","tamagoyaki","herbal_tea","chawanmushi","char_siu","dongpo","peking_duck"]
  },
};

// ---- BATCH SIMULATION ----
function runBatch(bA, bB, judgeId, n) {
  let wA=0, wB=0, ties=0, tSA=0, tSB=0;
  for (let i = 0; i < n; i++) {
    const qA = bA.dishes.map(id => D[id]).filter(Boolean);
    const qB = bB.dishes.map(id => D[id]).filter(Boolean);
    const r = simulate(qA, qB, judgeId);
    tSA += r.sA; tSB += r.sB;
    if (r.winner==="A") wA++; else if (r.winner==="B") wB++; else ties++;
  }
  return { wA, wB, ties, avgA: Math.round(tSA/n*10)/10, avgB: Math.round(tSB/n*10)/10,
           wrA: Math.round(wA/n*1000)/10 };
}

// ---- MAIN ----
function main() {
  const bNames = Object.keys(BUILDS);
  const jIds = Object.keys(JUDGES);

  console.log("=== 东方大巴扎 V2 数值模拟器 v2 ===\n");

  // Validate all dish references
  let missing = 0;
  for (const bn of bNames) {
    for (const did of BUILDS[bn].dishes) {
      if (!D[did]) { console.log(`  ⚠ ${BUILDS[bn].name}: 找不到菜品 "${did}"`); missing++; }
    }
  }
  if (missing > 0) { console.log(`\n${missing} 个菜品引用缺失，请检查\n`); }

  // Phase 1: Overall win rates
  console.log("--- Phase 1: 各流派综合胜率 (全评委) ---");
  const wr = {};
  for (const bn of bNames) {
    let wins=0, games=0, totalS=0;
    for (const opp of bNames) {
      if (opp === bn) continue;
      for (const jId of jIds) {
        const r = runBatch(BUILDS[bn], BUILDS[opp], jId, 1);
        wins += r.wA; games++; totalS += r.avgA;
      }
    }
    const rate = Math.round(wins/games*1000)/10;
    const avgS = Math.round(totalS/games*10)/10;
    wr[bn] = rate;
    console.log(`  ${BUILDS[bn].name.padEnd(8)} | 胜率 ${String(rate).padStart(5)}% | 均分 ${String(avgS).padStart(6)} | ${BUILDS[bn].desc}`);
  }

  // Phase 2: Win/Loss matrix (eiki neutral)
  console.log("\n--- Phase 2: 对战矩阵 (映姬) ---");
  const hdr = "          " + bNames.map(n => BUILDS[n].name.slice(0,4).padStart(5)).join("");
  console.log(hdr);
  for (const bA of bNames) {
    let row = BUILDS[bA].name.slice(0,8).padEnd(10);
    for (const bB of bNames) {
      if (bA===bB) { row += "  --- "; continue; }
      const r = runBatch(BUILDS[bA], BUILDS[bB], "eiki", 1);
      row += String(r.wrA > 50 ? "W" : r.wrA < 50 ? "L" : "T").padStart(5) + " ";
    }
    console.log(row);
  }

  // Phase 3: Judge impact
  console.log("\n--- Phase 3: 评委偏好影响 ---");
  for (const jId of jIds) {
    let best="", bestS=0, worst="", worstS=Infinity;
    for (const bn of bNames) {
      let ts=0, c=0;
      for (const opp of bNames) {
        if (opp===bn) continue;
        const r = runBatch(BUILDS[bn], BUILDS[opp], jId, 1);
        ts += r.avgA; c++;
      }
      const avg = ts/c;
      if (avg > bestS) { bestS=avg; best=BUILDS[bn].name; }
      if (avg < worstS) { worstS=avg; worst=BUILDS[bn].name; }
    }
    console.log(`  ${JUDGES[jId].name.padEnd(5)} | 最强: ${best.padEnd(8)} (${Math.round(bestS)}) | 最弱: ${worst.padEnd(8)} (${Math.round(worstS)})`);
  }

  // Phase 4: Sample timeline
  console.log("\n--- Phase 4: 示例对局 (辛辣连锁 vs 和食清淡, 映姬) ---");
  const qA = BUILDS.spicy_chain.dishes.map(id => D[id]).filter(Boolean);
  const qB = BUILDS.washoku_light.dishes.map(id => D[id]).filter(Boolean);
  const det = simulate(qA, qB, "eiki");
  for (const ev of det.timeline) {
    console.log(`  T=${String(ev.t).padStart(5)}s | ${ev.p} | ${(D[ev.dish]?.name||ev.dish).padEnd(8)} | 得分 ${String(ev.score).padStart(5)} | 饱腹 ${ev.sat}`);
  }
  console.log(`  结果: A=${Math.round(det.sA)} B=${Math.round(det.sB)} 胜者=${det.winner}`);

  // Phase 5: Speed rush dominance test
  console.log("\n--- Phase 5: 速攻流统治力 ---");
  for (const opp of bNames) {
    if (opp==="speed_rush") continue;
    let wins=0, total=0;
    for (const jId of jIds) {
      const r = runBatch(BUILDS.speed_rush, BUILDS[opp], jId, 1);
      wins += r.wA; total++;
    }
    const rate = Math.round(wins/total*100);
    const flag = rate > 70 ? " ⚠过强" : rate < 30 ? " ✓被克" : "";
    console.log(`  速攻 vs ${BUILDS[opp].name.padEnd(8)} | 胜率 ${rate}%${flag}`);
  }

  // Phase 6: Judge-specific build performance (which build shines where)
  console.log("\n--- Phase 6: 各流派最佳评委 ---");
  for (const bn of bNames) {
    let bestJ="", bestRate=0, worstJ="", worstRate=100;
    for (const jId of jIds) {
      let wins=0, games=0;
      for (const opp of bNames) {
        if (opp===bn) continue;
        const r = runBatch(BUILDS[bn], BUILDS[opp], jId, 1);
        wins += r.wA; games++;
      }
      const rate = Math.round(wins/games*100);
      if (rate > bestRate) { bestRate=rate; bestJ=JUDGES[jId].name; }
      if (rate < worstRate) { worstRate=rate; worstJ=JUDGES[jId].name; }
    }
    console.log(`  ${BUILDS[bn].name.padEnd(8)} | 最佳: ${bestJ.padEnd(4)} ${bestRate}% | 最差: ${worstJ.padEnd(4)} ${worstRate}%`);
  }

  // Summary
  console.log("\n=== 平衡性总结 ===");
  const sorted = bNames.sort((a,b) => wr[b] - wr[a]);
  const topN = sorted[0], botN = sorted[sorted.length-1];
  const spread = wr[topN] - wr[botN];
  console.log(`最强: ${BUILDS[topN].name} (${wr[topN]}%)`);
  console.log(`最弱: ${BUILDS[botN].name} (${wr[botN]}%)`);
  console.log(`极差: ${Math.round(spread*10)/10}%`);
  console.log("排名:");
  for (let i = 0; i < sorted.length; i++) {
    console.log(`  ${i+1}. ${BUILDS[sorted[i]].name.padEnd(8)} ${wr[sorted[i]]}%`);
  }
  if (spread > 30) console.log("\n⚠ 平衡性差距过大，需要调整");
  else if (spread > 20) console.log("\n⚠ 有一定差距，建议微调");
  else console.log("\n✓ 平衡性在合理范围内");
}

main();
