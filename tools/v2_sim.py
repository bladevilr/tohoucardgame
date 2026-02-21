#!/usr/bin/env python3
"""
TouhouBazaar V2 Auto-Balancing Simulation
Iterative test -> evaluate -> adjust -> retest loop
"""
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

import random, math, copy
from dataclasses import dataclass, field
from typing import List, Dict, Tuple
from collections import defaultdict

# ============================================================
# TUNABLE PARAMETERS (will be auto-adjusted)
# ============================================================
@dataclass
class Params:
    need_reward: float = 0.25          # score mult bonus per need satisfied
    combo_streak_bonus: float = 0.0    # per consecutive serve bonus
    satiety_base: Dict = field(default_factory=lambda: {1: 5, 2: 12, 3: 20})
    threshold_decay: float = 0.07      # freshness penalty per threshold level
    addiction_bonus: float = 0.04      # bonus per threshold in addiction mode
    addiction_threshold: int = 3       # consecutive same-flavor to trigger addiction
    quantity_bonus: float = 0.0        # bonus per dish served (rewards more dishes)
    satiety_slowdown_threshold: float = 0.7
    satiety_scoring_threshold: float = 0.9
    unsat_penalty: float = 2.0        # flat penalty per unsatisfied need

# ============================================================
# DISH DATA
# ============================================================
@dataclass(frozen=True)
class Dish:
    id: str; cuisine: str; tier: int; size: int; cooldown: float
    flavor: int; presentation: int; technique: int; aroma: int
    tags: tuple
    @property
    def budget_cost(self):
        return [1, 2, 4, 8][self.tier]

ALL_DISHES = [
    # CHUUKA
    Dish("scallion_pancake","chuuka",0,1,2.5,4,2,3,5,("stir_fried","vegetable","light")),
    Dish("mapo_tofu","chuuka",0,1,3.0,6,2,4,5,("tofu","spicy","numbing","stir_fried")),
    Dish("egg_fried_rice","chuuka",0,1,3.0,5,3,3,4,("egg","stir_fried","rice")),
    Dish("hot_sour_soup","chuuka",0,1,3.0,5,2,3,5,("soup","spicy","sour")),
    Dish("cucumber_salad","chuuka",0,1,1.5,3,2,2,3,("vegetable","light","sour","cold")),
    Dish("kung_pao_chicken","chuuka",1,1,5.0,10,4,6,7,("meat","stir_fried","spicy")),
    Dish("dan_dan_noodles","chuuka",1,1,4.0,8,3,5,6,("noodle","spicy","numbing")),
    Dish("sweet_sour_pork","chuuka",1,1,4.5,9,5,5,5,("meat","sour","sweet","deep_fried")),
    Dish("boiled_fish","chuuka",2,2,7.0,16,6,10,12,("seafood","spicy","numbing","soup")),
    Dish("sichuan_hotpot","chuuka",2,2,7.0,18,8,12,14,("spicy","numbing","soup","rich")),
    Dish("peking_duck","chuuka",2,3,9.0,22,24,20,18,("meat","roasted","rich")),
    Dish("buddha_jumps_wall","chuuka",3,3,12.0,24,18,22,20,("seafood","rich","soup")),
    # WASHOKU
    Dish("miso_soup","washoku",0,1,2.0,4,3,3,5,("soup","light","umami_tag")),
    Dish("tamagoyaki","washoku",0,1,2.5,4,4,4,3,("egg","sweet","light")),
    Dish("onigiri","washoku",0,1,2.0,3,2,2,3,("rice","light")),
    Dish("edamame","washoku",0,1,1.5,3,2,2,3,("vegetable","light")),
    Dish("udon_noodles","washoku",0,1,3.0,5,3,4,4,("noodle","soup","light")),
    Dish("yakitori","washoku",1,1,3.5,7,4,5,8,("meat","grilled")),
    Dish("tempura_shrimp","washoku",1,1,4.0,8,6,6,7,("seafood","deep_fried")),
    Dish("sashimi_platter","washoku",1,2,5.0,10,12,10,8,("seafood","raw","light","umami_tag")),
    Dish("kaiseki_plate","washoku",2,2,7.0,14,18,14,10,("raw","light","umami_tag")),
    Dish("unagi_don","washoku",2,2,6.0,16,10,12,14,("seafood","grilled","rich","rice")),
    Dish("omakase_sushi","washoku",3,3,10.0,20,22,18,16,("seafood","raw","umami_tag","rice")),
    # YOUSHOKU
    Dish("caesar_salad","youshoku",0,1,2.0,4,5,3,3,("vegetable","light","cheese")),
    Dish("french_onion_soup","youshoku",0,1,3.0,6,4,4,5,("soup","rich","cheese")),
    Dish("bread_basket","youshoku",0,1,1.5,3,3,2,3,("bread","light")),
    Dish("pasta_carbonara","youshoku",1,1,4.5,9,6,6,5,("noodle","rich","cheese","egg")),
    Dish("beef_stew","youshoku",1,2,6.0,12,8,8,9,("meat","rich","soup")),
    Dish("seafood_bisque","youshoku",1,1,4.0,8,7,6,7,("seafood","soup","rich")),
    Dish("duck_confit","youshoku",2,2,7.0,16,14,12,10,("meat","rich","roasted")),
    Dish("creme_brulee","youshoku",2,1,5.0,10,14,10,6,("sweet","dessert","rich")),
    Dish("lobster_thermidor","youshoku",2,2,8.0,18,16,14,12,("seafood","rich","cheese")),
    Dish("wellington_beef","youshoku",3,3,11.0,22,20,18,14,("meat","rich","roasted")),
    # YATAI
    Dish("grilled_corn","yatai",0,1,2.0,4,2,2,6,("vegetable","grilled")),
    Dish("yakisoba","yatai",0,1,2.5,5,2,3,5,("noodle","stir_fried")),
    Dish("takoyaki","yatai",0,1,2.5,5,3,3,6,("seafood","deep_fried")),
    Dish("karaage","yatai",0,1,2.5,5,3,3,6,("meat","deep_fried")),
    Dish("chicken_skewer","yatai",1,1,3.0,7,3,4,8,("meat","grilled","spicy")),
    Dish("grilled_squid","yatai",1,1,3.0,7,3,4,8,("seafood","grilled")),
    Dish("oden","yatai",1,1,3.5,6,4,5,6,("soup","light","umami_tag")),
    Dish("ramen","yatai",1,2,5.0,11,5,7,10,("noodle","soup","rich","umami_tag")),
    Dish("okonomiyaki","yatai",1,2,5.0,10,6,6,8,("meat","stir_fried","egg")),
    Dish("mystia_yakitori","yatai",2,2,5.5,14,6,8,14,("meat","grilled","rich")),
    Dish("festival_feast","yatai",3,3,8.0,18,10,12,18,("meat","grilled","rich")),
    # KANMI
    Dish("dango","kanmi",0,1,2.0,4,5,3,3,("sweet","light")),
    Dish("dorayaki","kanmi",0,1,2.5,5,5,3,3,("sweet",)),
    Dish("shaved_ice","kanmi",0,1,1.5,3,6,2,2,("sweet","cold","light")),
    Dish("matcha_cake","kanmi",1,1,4.0,7,10,6,5,("sweet","tea","dessert")),
    Dish("parfait","kanmi",1,1,3.5,6,9,5,4,("sweet","cold","dessert")),
    Dish("sakura_mochi","kanmi",1,1,3.0,6,8,5,4,("sweet","light")),
    Dish("mille_crepe","kanmi",1,1,4.0,7,10,6,4,("sweet","dessert","light")),
    Dish("tiramisu","kanmi",2,1,5.0,10,12,8,6,("sweet","rich","dessert","cheese")),
    Dish("chocolate_fondant","kanmi",2,2,6.0,14,14,10,8,("sweet","rich","dessert")),
    Dish("celestial_parfait","kanmi",3,2,7.0,16,18,12,10,("sweet","cold","dessert")),
    # YAKUZEN
    Dish("herb_tea","yakuzen",0,1,2.0,3,3,3,5,("tea","light")),
    Dish("goji_porridge","yakuzen",0,1,3.0,4,3,4,4,("light","soup","sweet")),
    Dish("chrysanthemum_tea","yakuzen",1,1,3.0,5,5,5,6,("tea","light")),
    Dish("ginseng_chicken","yakuzen",1,2,6.0,10,6,8,8,("meat","soup","rich")),
    Dish("medicinal_hotpot","yakuzen",1,2,6.0,9,5,7,8,("soup","spicy","rich")),
    Dish("five_element_soup","yakuzen",2,2,7.0,12,8,10,10,("soup","umami_tag")),
    Dish("yin_yang_tea","yakuzen",2,1,5.0,8,8,6,8,("tea","light")),
    Dish("matcha_medicine","yakuzen",2,1,5.0,8,7,6,8,("tea","light")),
    Dish("immortal_peach","yakuzen",2,1,6.0,10,8,6,8,("sweet",)),
    Dish("hourai_elixir","yakuzen",3,2,10.0,18,12,16,16,("rich",)),
    Dish("hakurei_feast","yakuzen",3,3,12.0,16,12,12,16,("light",)),
]
DISH_MAP = {d.id: d for d in ALL_DISHES}
FLAVOR_TAGS = {"spicy","sweet","umami_tag","sour","rich","numbing"}

# ============================================================
# JUDGES (fixed: Yuyuko never gets full)
# ============================================================
@dataclass
class Judge:
    id: str; name: str; gluttony: float; satiety_cap: float
    preferred: tuple; disliked: tuple; mods: dict

JUDGES = [
    Judge("yuyuko","幽幽子",1.8,99999,  # NEVER gets full
          ("umami_tag","rich","meat"),(),
          {"addiction_threshold":2,"need_mult":1.0}),
    Judge("eiki","映姬",0.5,100,
          (),(),
          {"addiction_threshold":3,"need_mult":1.5}),
    Judge("aya","文",0.7,100,
          ("surprising","fusion","rare"),(),
          {"addiction_threshold":3,"need_mult":1.0,"curiosity_mult":2.0}),
    Judge("remilia","蕾米莉亚",0.6,80,
          ("rich","cheese","meat"),("light",),
          {"addiction_threshold":3,"need_mult":1.0,"light_penalty":True}),
    Judge("raiko","雷鼓",1.2,100,
          (),(),
          {"addiction_threshold":3,"need_mult":1.0,"tempo":True}),
    Judge("tenshi","天子",1.0,100,
          (),(),
          {"addiction_threshold":3,"need_mult":1.0,"unsat_mult":2.0}),
]

# ============================================================
# NEED SYSTEM
# ============================================================
@dataclass
class Need:
    type: str; satisfiers: tuple; ttl: int; reward: float; player: int

def create_needs(dish, jstate, history, player):
    needs = []
    if any(t in dish.tags for t in ("spicy","numbing","roasted","grilled")):
        needs.append(Need("thirsty",("soup","tea","beverage","cold"),3,1.0,player))
    if any(t in dish.tags for t in ("rich","deep_fried","cheese")):
        needs.append(Need("greasy",("light","sour","tea","vegetable"),3,1.0,player))
    ph = [h for h in history if h[0]==player]
    if len(ph)>=2:
        recent = [h[1] for h in ph[-2:]]+[dish]
        if all(d.size==1 for d in recent) and not any(any(t in d.tags for t in ("rice","noodle","bread")) for d in recent):
            needs.append(Need("staple",("rice","noodle","bread"),4,1.2,player))
    if jstate["satiety"]>jstate["cap"]*0.5 and any(t in dish.tags for t in ("rich","meat")):
        needs.append(Need("dessert",("sweet","dessert"),4,1.0,player))
    if len(history)>=2:
        rc = [h[1].cuisine for h in history[-2:]]
        if dish.cuisine not in rc:
            needs.append(Need("curiosity",("__any__",),2,0.8,player))
    return needs

def satisfies(dish, need):
    if "__any__" in need.satisfiers:
        return True
    return any(t in dish.tags for t in need.satisfiers)

# ============================================================
# SIMULATION ENGINE
# ============================================================
def simulate(qa: List[Dish], qb: List[Dish], judge: Judge, p: Params) -> dict:
    state = {
        "satiety":0.0, "cap":judge.satiety_cap,
        "thresholds":defaultdict(float), "addiction":set(),
        "addiction_cnt":defaultdict(int), "needs":[], "mood":0.0,
        "scores_hist":[], "dishes_count":[0,0],
    }
    scores = [0.0, 0.0]
    served = [0, 0]
    history = []
    need_sat = [0, 0]
    queues = [list(qa), list(qb)]
    idx = [0, 0]
    ft = [queues[0][0].cooldown if qa else 1e9, queues[1][0].cooldown if qb else 1e9]

    for _ in range(300):
        # find next
        np_ = -1; nt = 1e9
        for pp in range(2):
            if idx[pp] < len(queues[pp]):
                if ft[pp] < nt or (ft[pp]==nt and np_>=0 and queues[pp][idx[pp]].aroma > queues[np_][idx[np_]].aroma):
                    nt = ft[pp]; np_ = pp
        if np_<0 or nt>30.0: break

        pl = np_; dish = queues[pl][idx[pl]]

        # --- SCORE ---
        base = dish.flavor
        quality = 0.8 + dish.technique/20.0
        # freshness
        fresh = 1.0
        addict_thresh = judge.mods.get("addiction_threshold", p.addiction_threshold)
        for t in dish.tags:
            if t in FLAVOR_TAGS:
                th = state["thresholds"][t]
                if t in state["addiction"]:
                    fresh *= 1.0 + th * p.addiction_bonus
                else:
                    fresh *= max(0.3, 1.0 - th * p.threshold_decay)
        # need satisfaction
        nb = 0.0; sat_list = []
        for n in state["needs"]:
            if satisfies(dish, n):
                r = n.reward * p.need_reward * judge.mods.get("need_mult",1.0)
                if n.type=="curiosity": r *= judge.mods.get("curiosity_mult",1.0)
                nb += r; sat_list.append(n)
        for n in sat_list: state["needs"].remove(n)
        need_sat[pl] += len(sat_list)
        # mood
        mood_m = 1.0 + state["mood"]*0.08
        # pref
        pref = 1.0
        for t in dish.tags:
            if t in judge.preferred: pref += 0.05
            if t in judge.disliked: pref -= 0.05
            if judge.mods.get("light_penalty") and t=="light": pref -= 0.08
        pref = max(0.5, min(1.5, pref))
        # unsat penalty
        up = len(state["needs"]) * p.unsat_penalty * judge.mods.get("unsat_mult",1.0)
        # satiety scoring
        sr = state["satiety"]/state["cap"] if state["cap"]>0 else 0
        sm = 1.0
        if sr > p.satiety_scoring_threshold:
            has_add = any(t in state["addiction"] for t in dish.tags if t in FLAVOR_TAGS)
            has_des = any(t in dish.tags for t in ("sweet","dessert"))
            sm = 0.8 if (has_add or has_des) else 0.3
        elif sr > p.satiety_slowdown_threshold:
            sm = 0.7
        # combo streak
        cb = 1.0 + served[pl] * p.combo_streak_bonus
        # quantity bonus
        qb_ = 1.0 + served[pl] * p.quantity_bonus

        score = max(0, base * quality * fresh * (1.0+nb) * mood_m * pref * sm * cb * qb_ - up)
        scores[pl] += score; served[pl] += 1; history.append((pl, dish))

        # --- UPDATE STATE ---
        # satiety (conditional)
        bs = p.satiety_base.get(dish.size, 5)
        avg_s = max(5, sum(state["scores_hist"])/len(state["scores_hist"])) if state["scores_hist"] else 10.0
        delicious = min(1.5, max(0.3, score/avg_s))
        pe = 1.0
        for t in dish.tags:
            if t in judge.preferred: pe=1.3; break
            if t in judge.disliked: pe=0.3; break
        state["satiety"] = min(state["cap"], state["satiety"] + bs*delicious*judge.gluttony*pe)
        # thresholds
        for t in dish.tags:
            if t in FLAVOR_TAGS:
                state["thresholds"][t] += 1.0
                state["addiction_cnt"][t] += 1
        for ft_ in FLAVOR_TAGS:
            if ft_ not in dish.tags:
                state["addiction_cnt"][ft_] = max(0, state["addiction_cnt"][ft_]-1)
        for ft_ in FLAVOR_TAGS:
            if state["addiction_cnt"][ft_] >= addict_thresh:
                state["addiction"].add(ft_)
        # palate cleansing
        if any(t in dish.tags for t in ("light","tea")):
            for ft_ in FLAVOR_TAGS:
                if ft_ not in dish.tags:
                    state["thresholds"][ft_] = max(0, state["thresholds"][ft_]-0.5)
        # mood
        md = 0.0
        for t in dish.tags:
            if t in judge.preferred: md += 0.5
            if t in judge.disliked: md -= 0.5
        if judge.mods.get("light_penalty") and "light" in dish.tags: md -= 0.8
        state["mood"] = max(-5, min(5, state["mood"]+md))
        # create needs
        nn = create_needs(dish, state, history, pl)
        state["needs"].extend(nn)
        # age needs
        for n in state["needs"]: n.ttl -= 1
        state["needs"] = [n for n in state["needs"] if n.ttl>0]
        state["scores_hist"].append(score)

        # advance
        idx[pl] += 1
        if idx[pl] < len(queues[pl]):
            cd = queues[pl][idx[pl]].cooldown
            if sr > p.satiety_slowdown_threshold: cd *= 1.3
            if judge.mods.get("tempo") and len(sat_list)>0:
                cd = max(0.5, cd - len(sat_list)*0.5)
            ft[pl] = nt + cd
        else:
            ft[pl] = 1e9

    w = 0 if scores[0]>scores[1] else (1 if scores[1]>scores[0] else -1)
    return {"scores":scores,"winner":w,"served":served,
            "satiety":state["satiety"]/state["cap"] if state["cap"]<90000 else 0,
            "need_sat":need_sat,"addiction":list(state["addiction"])}

# ============================================================
# BUILD SYSTEM (budget-constrained)
# ============================================================
BUDGET_LEVELS = {"early":10, "mid":22, "late":50}

def best_dishes_for_tags(target_tags, max_tier, count, exclude=set()):
    """Pick best dishes matching any target tag, within tier limit."""
    candidates = [d for d in ALL_DISHES if d.tier<=max_tier and d.id not in exclude
                  and any(t in d.tags for t in target_tags)]
    candidates.sort(key=lambda d: -d.flavor)
    return candidates[:count]

def best_dishes_for_cuisine(cuisine, max_tier, count):
    candidates = [d for d in ALL_DISHES if d.tier<=max_tier and d.cuisine==cuisine]
    candidates.sort(key=lambda d: -d.flavor)
    return candidates[:count]

def build_within_budget(archetype: str, budget: int) -> List[Dish]:
    """Generate a build for an archetype within budget constraints."""
    max_tier = 0 if budget<=10 else (1 if budget<=15 else (2 if budget<=30 else 3))
    # Select dishes greedily within budget
    if archetype == "speed_rush":
        pool = sorted([d for d in ALL_DISHES if d.size==1 and d.tier<=max_tier],
                      key=lambda d: d.cooldown)
        return _fill_budget(pool, budget)
    elif archetype == "pure_spicy":
        pool = sorted([d for d in ALL_DISHES if "spicy" in d.tags and d.tier<=max_tier],
                      key=lambda d: -d.flavor)
        return _fill_budget(pool, budget)
    elif archetype == "pure_sweet":
        pool = sorted([d for d in ALL_DISHES if "sweet" in d.tags and d.tier<=max_tier],
                      key=lambda d: -d.flavor)
        return _fill_budget(pool, budget)
    elif archetype == "big_value":
        pool = sorted([d for d in ALL_DISHES if d.size>=2 and d.tier<=max_tier],
                      key=lambda d: -d.flavor)
        return _fill_budget(pool, budget)
    elif archetype == "need_chain":
        # Alternate spicy/soup/rich/light
        heavy = [d for d in ALL_DISHES if d.tier<=max_tier and any(t in d.tags for t in ("spicy","rich","roasted","grilled"))]
        light = [d for d in ALL_DISHES if d.tier<=max_tier and any(t in d.tags for t in ("soup","tea","light","sweet","sour"))]
        heavy.sort(key=lambda d:-d.flavor); light.sort(key=lambda d:-d.flavor)
        result = []; cost = 0; hi=0; li=0; toggle=True
        while cost < budget and (hi<len(heavy) or li<len(light)):
            if toggle and hi<len(heavy) and cost+heavy[hi].budget_cost<=budget:
                result.append(heavy[hi]); cost+=heavy[hi].budget_cost; hi+=1
            elif not toggle and li<len(light) and cost+light[li].budget_cost<=budget:
                result.append(light[li]); cost+=light[li].budget_cost; li+=1
            elif hi<len(heavy) and cost+heavy[hi].budget_cost<=budget:
                result.append(heavy[hi]); cost+=heavy[hi].budget_cost; hi+=1
            elif li<len(light) and cost+light[li].budget_cost<=budget:
                result.append(light[li]); cost+=light[li].budget_cost; li+=1
            else: break
            toggle = not toggle
        return result
    elif archetype == "washoku":
        pool = sorted([d for d in ALL_DISHES if d.cuisine=="washoku" and d.tier<=max_tier],
                      key=lambda d:-d.flavor)
        return _fill_budget(pool, budget)
    elif archetype == "yatai":
        pool = sorted([d for d in ALL_DISHES if d.cuisine=="yatai" and d.tier<=max_tier],
                      key=lambda d:-d.flavor)
        return _fill_budget(pool, budget)
    elif archetype == "youshoku":
        pool = sorted([d for d in ALL_DISHES if d.cuisine=="youshoku" and d.tier<=max_tier],
                      key=lambda d:-d.flavor)
        return _fill_budget(pool, budget)
    elif archetype == "yakuzen":
        pool = sorted([d for d in ALL_DISHES if d.cuisine=="yakuzen" and d.tier<=max_tier],
                      key=lambda d:-d.flavor)
        return _fill_budget(pool, budget)
    elif archetype == "balanced":
        # one from each cuisine
        cuisines = ["chuuka","washoku","youshoku","yatai","kanmi","yakuzen"]
        result = []; cost = 0
        for c in cuisines:
            pool = [d for d in ALL_DISHES if d.cuisine==c and d.tier<=max_tier and cost+d.budget_cost<=budget]
            if pool:
                best = max(pool, key=lambda d: d.flavor)
                result.append(best); cost+=best.budget_cost
        # fill remaining budget
        remaining = [d for d in ALL_DISHES if d.tier<=max_tier and d not in result]
        remaining.sort(key=lambda d:-d.flavor)
        for d in remaining:
            if cost+d.budget_cost<=budget:
                result.append(d); cost+=d.budget_cost
        return result
    return []

def _fill_budget(pool, budget):
    result = []; cost = 0
    for d in pool:
        if cost + d.budget_cost <= budget:
            result.append(d); cost += d.budget_cost
    return result

ARCHETYPES = ["speed_rush","pure_spicy","pure_sweet","big_value","need_chain",
              "washoku","yatai","youshoku","yakuzen","balanced"]
SHORT = {"speed_rush":"速攻","pure_spicy":"纯辣","pure_sweet":"纯甜","big_value":"大菜",
         "need_chain":"链式","washoku":"和食","yatai":"夜市","youshoku":"西餐",
         "yakuzen":"药膳","balanced":"均衡"}

# ============================================================
# BATCH RUNNER
# ============================================================
def run_batch(ba, bb, judge, p, n=100):
    wins=[0,0,0]; ts=[0.0,0.0]
    for i in range(n):
        if i%2==0: qa,qb=list(ba),list(bb)
        else: qa,qb=list(bb),list(ba)
        r = simulate(qa,qb,judge,p)
        if i%2==0:
            ts[0]+=r["scores"][0]; ts[1]+=r["scores"][1]
            w=r["winner"]
        else:
            ts[0]+=r["scores"][1]; ts[1]+=r["scores"][0]
            w = 1-r["winner"] if r["winner"]>=0 else -1
        if w==0: wins[0]+=1
        elif w==1: wins[1]+=1
        else: wins[2]+=1
    return {"a_wr":wins[0]/n, "b_wr":wins[1]/n, "a_avg":ts[0]/n, "b_avg":ts[1]/n}

# ============================================================
# BALANCE EVALUATOR
# ============================================================
def evaluate_balance(p: Params, budget_name: str, budget: int, n_per_match=80):
    """Run all matchups at a budget level, return balance metrics."""
    builds = {}
    for a in ARCHETYPES:
        b = build_within_budget(a, budget)
        if len(b) >= 2:
            builds[a] = b

    active = list(builds.keys())
    if len(active) < 3:
        return None

    matrix = {}
    avg_scores = defaultdict(float)
    for a in active:
        matrix[a] = {}
        for b in active:
            if a==b: matrix[a][b]=0.5; continue
            total_wr = 0.0; cnt = 0
            for j in JUDGES:
                r = run_batch(builds[a], builds[b], j, p, n_per_match)
                total_wr += r["a_wr"]; cnt += 1
                avg_scores[a] += r["a_avg"]
            matrix[a][b] = total_wr/cnt

    # Calculate metrics
    wrs = {}
    for a in active:
        others = [b for b in active if b!=a]
        if others:
            wrs[a] = sum(matrix[a][b] for b in others)/len(others)
        else:
            wrs[a] = 0.5

    wr_list = list(wrs.values())
    metrics = {
        "wrs": wrs,
        "matrix": matrix,
        "active": active,
        "wr_range": max(wr_list)-min(wr_list) if wr_list else 0,
        "wr_max": max(wr_list) if wr_list else 0.5,
        "wr_min": min(wr_list) if wr_list else 0.5,
        "best": max(wrs, key=wrs.get),
        "worst": min(wrs, key=wrs.get),
    }
    return metrics

# ============================================================
# AUTO-TUNER
# ============================================================
def auto_tune(p: Params, metrics: dict, budget_name: str) -> Params:
    """Adjust parameters based on balance metrics."""
    new_p = Params(**{
        'need_reward': p.need_reward,
        'combo_streak_bonus': p.combo_streak_bonus,
        'satiety_base': dict(p.satiety_base),
        'threshold_decay': p.threshold_decay,
        'addiction_bonus': p.addiction_bonus,
        'addiction_threshold': p.addiction_threshold,
        'quantity_bonus': p.quantity_bonus,
        'satiety_slowdown_threshold': p.satiety_slowdown_threshold,
        'satiety_scoring_threshold': p.satiety_scoring_threshold,
        'unsat_penalty': p.unsat_penalty,
    })

    wrs = metrics["wrs"]
    best = metrics["best"]
    worst = metrics["worst"]
    best_wr = wrs[best]
    worst_wr = wrs[worst]

    # Rule 1: If speed_rush too weak, boost combo streak and quantity bonus
    if "speed_rush" in wrs and wrs["speed_rush"] < 0.35:
        new_p.combo_streak_bonus = min(0.20, new_p.combo_streak_bonus + 0.02)
        new_p.quantity_bonus = min(0.10, new_p.quantity_bonus + 0.01)

    # Rule 2: If big_value too strong, increase satiety base for large
    if "big_value" in wrs and wrs["big_value"] > 0.60:
        new_p.satiety_base[3] = min(50, new_p.satiety_base[3] + 3)
        new_p.satiety_base[2] = min(25, new_p.satiety_base[2] + 2)

    # Rule 3: If need_chain not outperforming, boost need reward
    if "need_chain" in wrs and "balanced" in wrs:
        if wrs["need_chain"] < wrs["balanced"] + 0.05:
            new_p.need_reward = min(1.5, new_p.need_reward + 0.05)

    # Rule 4: If pure builds (spicy/sweet) too weak, boost addiction
    for pure in ["pure_spicy", "pure_sweet"]:
        if pure in wrs and wrs[pure] < 0.35:
            new_p.addiction_bonus = min(0.15, new_p.addiction_bonus + 0.01)

    # Rule 5: If pure builds too strong, increase threshold decay
    for pure in ["pure_spicy", "pure_sweet"]:
        if pure in wrs and wrs[pure] > 0.60:
            new_p.threshold_decay = min(0.15, new_p.threshold_decay + 0.005)

    # Rule 6: General compression - if range too wide, buff weak and nerf strong
    if metrics["wr_range"] > 0.25:
        # Increase need reward (helps diverse builds)
        new_p.need_reward = min(1.5, new_p.need_reward + 0.03)
        # Increase unsat penalty (punishes builds that ignore needs)
        new_p.unsat_penalty = min(8.0, new_p.unsat_penalty + 0.3)

    return new_p

# ============================================================
# MAIN: Iterative balance loop
# ============================================================
def main():
    random.seed(42)
    p = Params()
    MAX_ITERATIONS = 15
    TARGET_RANGE = 0.25  # want wr_range < this

    print("="*70)
    print("东方大巴扎 V2 自动平衡模拟")
    print("="*70)
    print(f"菜品: {len(ALL_DISHES)} | 流派: {len(ARCHETYPES)} | 评委: {len(JUDGES)}")
    print(f"预算等级: {BUDGET_LEVELS}")
    print(f"目标: 所有流派胜率极差 < {TARGET_RANGE:.0%}")
    print()

    # Iterate per budget level
    for bname, budget in BUDGET_LEVELS.items():
        print("="*70)
        print(f"[{bname.upper()} 阶段] 预算={budget} (对应Day {'1-3' if bname=='early' else '4-7' if bname=='mid' else '8+'})")
        print("="*70)

        # Show builds at this budget
        print(f"\n  各流派在预算{budget}下的编成:")
        for a in ARCHETYPES:
            b = build_within_budget(a, budget)
            cost = sum(d.budget_cost for d in b)
            tiers = [d.tier for d in b]
            avg_tier = sum(tiers)/len(tiers) if tiers else 0
            names = [d.id[:12] for d in b[:5]]
            more = f"...+{len(b)-5}" if len(b)>5 else ""
            print(f"    {SHORT[a]:>4}: {len(b)}道(费{cost}) 均品{avg_tier:.1f} [{', '.join(names)}{more}]")

        # Iterative tuning
        current_p = Params(**{
            'need_reward': p.need_reward, 'combo_streak_bonus': p.combo_streak_bonus,
            'satiety_base': dict(p.satiety_base), 'threshold_decay': p.threshold_decay,
            'addiction_bonus': p.addiction_bonus, 'addiction_threshold': p.addiction_threshold,
            'quantity_bonus': p.quantity_bonus,
            'satiety_slowdown_threshold': p.satiety_slowdown_threshold,
            'satiety_scoring_threshold': p.satiety_scoring_threshold,
            'unsat_penalty': p.unsat_penalty,
        })

        best_metrics = None
        best_range = 999

        for iteration in range(MAX_ITERATIONS):
            metrics = evaluate_balance(current_p, bname, budget, n_per_match=60)
            if metrics is None:
                print(f"  轮{iteration+1}: 可用流派不足, 跳过")
                break

            wr_range = metrics["wr_range"]
            if wr_range < best_range:
                best_range = wr_range
                best_metrics = metrics
                best_p = Params(**{
                    'need_reward': current_p.need_reward,
                    'combo_streak_bonus': current_p.combo_streak_bonus,
                    'satiety_base': dict(current_p.satiety_base),
                    'threshold_decay': current_p.threshold_decay,
                    'addiction_bonus': current_p.addiction_bonus,
                    'addiction_threshold': current_p.addiction_threshold,
                    'quantity_bonus': current_p.quantity_bonus,
                    'satiety_slowdown_threshold': current_p.satiety_slowdown_threshold,
                    'satiety_scoring_threshold': current_p.satiety_scoring_threshold,
                    'unsat_penalty': current_p.unsat_penalty,
                })

            best_a = metrics["best"]; worst_a = metrics["worst"]
            print(f"  轮{iteration+1}: 极差={wr_range:.1%} | "
                  f"最强={SHORT[best_a]}({metrics['wrs'][best_a]:.0%}) "
                  f"最弱={SHORT[worst_a]}({metrics['wrs'][worst_a]:.0%}) | "
                  f"需求奖励={current_p.need_reward:.2f} 连击={current_p.combo_streak_bonus:.2f} "
                  f"数量={current_p.quantity_bonus:.2f} 饱腹L={current_p.satiety_base[3]}")

            if wr_range <= TARGET_RANGE:
                print(f"  >>> 达到平衡目标!")
                break

            # Auto-tune
            current_p = auto_tune(current_p, metrics, bname)

        # Report final state
        if best_metrics:
            print(f"\n  [{bname.upper()}] 最终胜率矩阵 (极差={best_range:.1%}):")
            active = best_metrics["active"]
            header = f"{'':>6}" + "".join(f"{SHORT.get(b,b[:4]):>6}" for b in active)
            print(f"  {header}")
            for a in active:
                row = f"  {SHORT.get(a,a[:4]):>6}"
                for b in active:
                    row += f"{best_metrics['matrix'][a][b]:6.0%}"
                row += f"  | {best_metrics['wrs'][a]:.0%}"
                print(row)

            # Update global params for next budget level
            p = best_p

    # ============================================================
    # FINAL REPORT
    # ============================================================
    print("\n" + "="*70)
    print("最终推荐参数")
    print("="*70)
    print(f"  need_reward (需求满足奖励):     {p.need_reward:.2f}")
    print(f"  combo_streak_bonus (连击加成):   {p.combo_streak_bonus:.2f}")
    print(f"  quantity_bonus (上菜数量加成):   {p.quantity_bonus:.2f}")
    print(f"  satiety_base (饱腹基数):         size1={p.satiety_base[1]} size2={p.satiety_base[2]} size3={p.satiety_base[3]}")
    print(f"  threshold_decay (味觉递减):      {p.threshold_decay:.3f}")
    print(f"  addiction_bonus (上瘾加成):       {p.addiction_bonus:.3f}")
    print(f"  unsat_penalty (未满足惩罚):      {p.unsat_penalty:.1f}")
    print(f"  satiety_slowdown (减速阈值):     {p.satiety_slowdown_threshold:.1%}")
    print(f"  satiety_scoring (扣分阈值):      {p.satiety_scoring_threshold:.1%}")

    # Final comprehensive test with tuned params
    print("\n" + "="*70)
    print("调参后终验 (全预算级别)")
    print("="*70)

    for bname, budget in BUDGET_LEVELS.items():
        metrics = evaluate_balance(p, bname, budget, n_per_match=100)
        if not metrics: continue
        print(f"\n  [{bname.upper()} 预算={budget}] 极差={metrics['wr_range']:.1%}")
        for a in sorted(metrics["active"], key=lambda x:-metrics["wrs"][x]):
            wr = metrics["wrs"][a]
            flag = " [!强]" if wr>0.60 else (" [!弱]" if wr<0.40 else " [OK]")
            print(f"    {SHORT[a]:>4}: {wr:.0%}{flag}")

    # Key conclusions
    print("\n" + "="*70)
    print("核心结论")
    print("="*70)

    final_m = evaluate_balance(p, "mid", BUDGET_LEVELS["mid"], n_per_match=120)
    if final_m:
        wr_r = final_m["wr_range"]
        print(f"  中期(Day 4-7)流派极差: {wr_r:.1%}", end="")
        if wr_r < 0.20: print(" -> 平衡度优秀")
        elif wr_r < 0.30: print(" -> 平衡度可接受")
        else: print(" -> 仍需调整")

        # Check specific builds
        for key, label in [("speed_rush","速攻"), ("big_value","大菜"), ("need_chain","需求链")]:
            if key in final_m["wrs"]:
                wr = final_m["wrs"][key]
                print(f"  {label}流胜率: {wr:.0%}", end="")
                if 0.40<=wr<=0.60: print(" -> 健康")
                elif wr<0.40: print(" -> 偏弱, 建议继续提升相关加成")
                else: print(" -> 偏强, 建议增加对应惩罚")

        # Counter relationships
        print(f"\n  克制关系(>65%胜率):")
        for a in final_m["active"]:
            for b in final_m["active"]:
                if a!=b and final_m["matrix"][a][b]>0.65:
                    print(f"    {SHORT[a]} > {SHORT[b]} ({final_m['matrix'][a][b]:.0%})")

    print("\n  [完成] 自动平衡模拟结束")

if __name__ == "__main__":
    main()
