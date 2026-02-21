# 菜品效果重设计规格文档

## 一、用户需求

当前菜品效果过于单调，大量菜品只有「获得N层焦香/鲜美」这类堆叠词条的效果。
目标：让每道菜具备**混合触发条件 × 混合效果**的设计，形成连携组合玩法。

### 期望的触发条件类型
| 类型 | 示例 |
|------|------|
| 自身激活时 | 激活时 → 效果 |
| 相邻菜品激活时 | 相邻激活 → 效果 |
| 持有特定词条时 | 焦香≥3层 → 消耗爆发 |
| 相邻有特定标签 | 相邻有「烤」→ 加成 |
| 相邻有特定菜系 | 相邻有中餐 → 效果 |
| 使用小型菜品时 | 相邻小型激活 → 效果 |
| 累积触发 | 每3次激活 → 爆发效果 |
| 位置条件 | 在最左/最右 → 特殊效果 |
| 随机概率 | 40%概率 → 倍率爆发 |

### 期望的效果类型
| 效果 | 代码键 |
|------|--------|
| 缩减冷却（直接缩短CD） | `reduce_cooldown_self / reduce_cooldown_adjacent` |
| 加速（临时冷却倍速） | `haste / haste_adjacent` |
| 减速对手 | `slow` |
| 风味倍率 | `flavor_mult` |
| 词条叠加 | `add_keyword` |
| 词条消耗爆发 | `if_keyword_gte → consume → bonus` |
| 词条转换 | `convert_keyword` |
| 词条传递给相邻 | `chain_right / chain_left` |
| 清除环境词条 | `clear_environment` |
| 给对手加负面环境 | `add_environment (opponent)` |
| 连锁触发相邻 | `chain_right range: N` |

---

## 二、当前系统能力（可直接用于菜品数据）

```gdscript
# 触发结构
{
    "event": "item_activated",
    "condition": "self",          # 或省略（任意激活都触发）
    "effect": { ... },
    "desc": "文字说明"
}

# 条件判断（写在effect里）
"if_adjacent_has_tag": "grilled"         # 相邻有此标签
"if_keyword_gte": {"keyword": "char_aroma", "stacks": 3}  # 词条≥N层
"if_position": "leftmost"               # 位置条件
"accumulate": {counter_id, increment, threshold, on_threshold: {...}}  # 累积
"random_chance": 0.4                    # 随机概率

# CD效果（已接入ShowdownResolver）
"reduce_cooldown_self": 0.5             # 缩减自身0.5秒
"reduce_cooldown_adjacent": 0.3         # 缩减相邻0.3秒
"haste": 2.0, "haste_mult": 2.0         # 加速自身2秒（速度×2）
"haste_adjacent": 1.5, "haste_mult": 2.0  # 加速相邻
"slow": 2.0, "slow_mult": 0.5          # 减速对手2秒（速度×0.5）

# 链式与传递
"chain_right": {"range": 2, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}
"copy_adjacent_keyword": {"target": "left", "keyword": "any", "stacks": 1}
```

---

## 三、各菜系设计定位

### 🍢 夜市（Yatai）— 爆香连携流
- **核心词条**：焦香（char_aroma）、油腻（greasy）
- **设计方向**：焦香积累 → 阈值爆发大伤害；油腻双刃剑（自产又能转化）；烤物互相加速
- **连携设计**：「烤串激活时 → 向右传焦香」→「焦香≥3 → 消耗爆发」→「清除油腻 → 获得焦香」

### 🍱 和食（Washoku）— 精进蓄力流
- **核心词条**：鲜美（umami）、刀工（knife_work）、回味（aftertaste）
- **设计方向**：大型菜（size 2-3）高基数 + 相邻小型菜支援加速；位置条件（最左开场、最右收尾）；鲜美积累后触发精进效果
- **连携设计**：「小型菜激活 → 给最近大型菜缩减CD」→「大型菜触发 → 全体获得回味」

### 🥟 中华（Chuuka）— 旺火速攻流
- **核心词条**：爆香（char_aroma）、鲜美（umami）
- **设计方向**：短CD快速轮转；相邻中餐激活时互相加速；小型菜链式触发；旺火短暂加速全场
- **连携设计**：「中华菜激活 → 相邻中华缩减CD 0.3秒」→「每3次激活 → 获得加速buff」

### 🍝 洋食（Youshoku）— 浓郁摆盘流
- **核心词条**：摆盘（plating）、浓郁（rich）
- **设计方向**：高风味基数 + 摆盘词条叠加；大型菜触发连锁摆盘传递；卖相压制机制配合
- **连携设计**：「摆盘≥3 → 激活时风味×1.8」→「相邻有浓郁标签 → 激活后加速」

### 🍡 甜品（Kanmi）— 回味回复流
- **核心词条**：回味（aftertaste）、甜（sweet）
- **设计方向**：积累回味 → 后期爆发；清除负面词条（油腻/疲劳）获得奖励；小型甜品快速触发支援大型甜品
- **连携设计**：「每激活2次 → 清除1层油腻 + 获得回味」→「回味≥5 → 大型甜品风味×2」

### 🌿 药膳（Yakuzen）— 解毒支援流
- **核心词条**：回味（aftertaste）、鲜美（umami）
- **设计方向**：大量清除负面环境词条；给相邻减CD；积累后触发全场加速；解毒获得额外奖励
- **连携设计**：「清除油腻/疲劳 → 相邻所有菜缩减CD」→「每清除3次 → 全场加速1秒」

---

## 四、效果设计模板示例

### 示例1：阈值爆发型
```gdscript
# 焦香≥3层时消耗并爆发，否则积累
{
    "event": "item_activated", "condition": "self",
    "effect": {
        "if_keyword_gte": {"keyword": "char_aroma", "stacks": 3},
        "then": {"consume_keyword": "char_aroma", "keyword_stacks": 3, "flavor_mult": 2.0},
        "else": {"add_keyword": "char_aroma", "keyword_stacks": 1}
    },
    "desc": "焦香≥3层时消耗爆发风味×2，否则获得1层焦香"
}
```

### 示例2：相邻标签联动
```gdscript
# 相邻有烤物 → 获得缩减 + 焦香
{
    "event": "item_activated", "condition": "self",
    "effect": {
        "add_keyword": "char_aroma", "keyword_stacks": 1,
        "if_adjacent_has_tag": "grilled",
        "then_bonus": {"reduce_cooldown_self": 0.5}
    },
    "desc": "获得1层焦香；若相邻有烤物，缩减自身冷却0.5秒"
}
```

### 示例3：累积 + 加速爆发
```gdscript
# 每激活3次，给相邻菜品加速2秒
{
    "event": "item_activated", "condition": "self",
    "effect": {
        "accumulate": {
            "counter_id": "wok_heat",
            "increment": 1,
            "threshold": 3,
            "reset_counter": true,
            "on_threshold": {"haste_adjacent": 2.0, "haste_mult": 2.0}
        }
    },
    "desc": "每激活3次，相邻菜品加速2秒（冷却速度×2）"
}
```

### 示例4：词条传递链
```gdscript
# 激活时获得鲜美并向两侧传递
{
    "event": "item_activated", "condition": "self",
    "effect": {
        "add_keyword": "umami", "keyword_stacks": 2,
        "chain_right": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}},
        "chain_left": {"range": 1, "effect": {"add_keyword": "umami", "keyword_stacks": 1}}
    },
    "desc": "获得2层鲜美，并向两侧传递1层鲜美"
}
```

---

## 五、实施计划

1. **一次重写一个菜系文件**，每个菜系约20-30道菜
2. 每道菜至少有一个**非平凡触发条件**（不只是"激活时获得词条"）
3. 每个菜系内部形成**至少3条连携链路**（A触发给B提供资源，B触发爆发）
4. Tier越高，效果越复杂（组合条件 + 组合效果）
5. 保留现有 id、name、cuisine、tier、size、cooldown、flavor、mod_slots、tags 不变，只改 triggers 和 on_activate

## 六、待支持的新触发事件（后续TriggerSystem扩展）

下列事件当前 **未实现**，菜品数据可以预留但不会生效，等系统扩展：
- `"event": "adjacent_activated"` — 相邻任意菜品激活时触发
- `"event": "keyword_threshold"` — 玩家总词条达到某阈值时触发
- `"event": "on_crit"` — 本次激活判定为暴击时触发
