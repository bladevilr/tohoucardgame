# 菜品效果扩展设计 - 大巴扎风格

## 设计目标
1. 增加效果多样性，避免大量"add_keyword X stacks 1"的重复
2. 引入更多互动机制：连锁反应、条件爆发、位置依赖、时间延迟等
3. 修复12张无效果菜品
4. 差异化 Tier 0 同质化菜品

---

## 新效果类型（参考大巴扎）

### 1. 延迟触发效果（Delayed Trigger）
**概念**：菜品激活后，效果在N回合后触发
```gdscript
{
  "event": "self_activate",
  "effect": {
    "delayed_trigger": {
      "delay_ticks": 2,
      "effect": {"add_keyword": "umami", "keyword_stacks": 3}
    }
  }
}
```
**应用场景**：
- 腌制类菜品（泡菜、腊肉）：激活后2回合发酵完成，爆发鲜美
- 炖煮类菜品（佛跳墙、东坡肉）：慢炖3回合后风味翻倍

---

### 2. 连锁反应（Chain Reaction）
**概念**：触发后，向左/右传播效果
```gdscript
{
  "event": "self_activate",
  "effect": {
    "chain_left": {
      "range": 2,
      "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}
    }
  }
}
```
**应用场景**：
- 火锅底料：激活后向右传播焦香给相邻2个菜品
- 香料：向左右各传播1层香气

---

### 3. 条件爆发（Conditional Burst）
**概念**：满足条件时效果翻倍/触发特殊效果
```gdscript
{
  "event": "self_activate",
  "effect": {
    "if_keyword_gte": {"keyword": "char_aroma", "stacks": 3},
    "then": {"consume_keyword": "char_aroma", "per_stack_flavor_bonus": 8.0},
    "else": {"add_keyword": "char_aroma", "keyword_stacks": 1}
  }
}
```
**应用场景**：
- 爆炒菜品：焦香≥3层时消耗全部焦香爆发，否则只加1层
- 刺身拼盘：刀工≥2层时卖相×2

---

### 4. 位置依赖（Position-Based）
**概念**：根据菜品在棋盘上的位置触发不同效果
```gdscript
{
  "event": "self_activate",
  "condition": {"if_position": "leftmost"},
  "effect": {"stat_bonus": {"flavor": 5}}
}
```
**应用场景**：
- 前菜（最左）：在最左侧时风味+5
- 主菜（中间）：左右各有1个菜品时效果翻倍
- 甜点（最右）：在最右侧时卖相+8

---

### 5. 牺牲/消耗机制（Sacrifice）
**概念**：消耗自身或其他菜品换取强力效果
```gdscript
{
  "event": "self_activate",
  "effect": {
    "sacrifice_self": true,
    "grant_to_adjacent": {"add_keyword": "secret_recipe", "keyword_stacks": 2}
  }
}
```
**应用场景**：
- 调味料：激活后自毁，给相邻菜品+2层秘方
- 食材：消耗后给全场+3金币

---

### 6. 复制/镜像（Copy/Mirror）
**概念**：复制相邻菜品的效果或属性
```gdscript
{
  "event": "self_activate",
  "effect": {
    "copy_adjacent_effect": true,
    "target": "left"
  }
}
```
**应用场景**：
- 模仿料理：复制左侧菜品的触发效果
- 拼盘：获得相邻菜品50%的属性

---

### 7. 转换/变形（Transform）
**概念**：将一种关键词转换为另一种
```gdscript
{
  "event": "self_activate",
  "effect": {
    "convert_keyword": {
      "from": "greasy",
      "to": "char_aroma",
      "ratio": 1.0
    }
  }
}
```
**应用场景**：
- 油炸菜品：将油腻转化为焦香
- 清蒸菜品：将焦香转化为鲜美

---

### 8. 冷却操控（Cooldown Manipulation）
**概念**：加速/减速自身或其他菜品的冷却
```gdscript
{
  "event": "self_activate",
  "effect": {
    "reduce_cooldown_adjacent": 1.0,  # 相邻菜品CD-1秒
    "increase_self_cooldown": 0.5     # 自身CD+0.5秒
  }
}
```
**应用场景**：
- 快炒菜品：激活后自身CD-0.5秒
- 慢炖菜品：激活后相邻菜品CD+1秒，但自身风味×2

---

### 9. 随机效果（Random Effect）
**概念**：从多个效果中随机选择一个
```gdscript
{
  "event": "self_activate",
  "effect": {
    "random_choice": [
      {"add_keyword": "umami", "keyword_stacks": 2},
      {"add_keyword": "char_aroma", "keyword_stacks": 2},
      {"add_keyword": "plating", "keyword_stacks": 2}
    ]
  }
}
```
**应用场景**：
- 魔理沙的魔法料理：随机获得一种关键词
- 神秘香料：随机效果

---

### 10. 累积/充能（Accumulate/Charge）
**概念**：每次激活累积充能，达到阈值后爆发
```gdscript
{
  "event": "self_activate",
  "effect": {
    "accumulate": {
      "counter_id": "charge",
      "increment": 1,
      "threshold": 3,
      "on_threshold": {"stat_bonus": {"flavor": 15}, "reset_counter": true}
    }
  }
}
```
**应用场景**：
- 发酵食品：每次激活+1充能，3次后爆发+15风味
- 连击菜品：连续激活3次后下次效果×3

---

### 11. 反弹/反制（Reflect/Counter）
**概念**：将负面效果反弹给对手
```gdscript
{
  "event": "environment_applied",
  "condition": {"env_keyword": "greasy"},
  "effect": {
    "reflect_to_opponent": true,
    "clear_self": true
  }
}
```
**应用场景**：
- 清淡菜品：受到油腻时反弹给对手并清除自身
- 药膳：受到味觉疲劳时转化为回味

---

### 12. 吸取/吸血（Drain/Lifesteal）
**概念**：从对手或环境中吸取资源
```gdscript
{
  "event": "self_activate",
  "effect": {
    "drain_opponent_keyword": {
      "keyword": "umami",
      "stacks": 1
    }
  }
}
```
**应用场景**：
- 掠夺菜品：激活时偷取对手1层鲜美
- 寄生菜品：每回合吸取相邻菜品的属性

---

## 修复无效果菜品（12张）

### Chuuka（中华）
1. **gyoza（饺子）** - Tier 0
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "if_adjacent_count_gte": 2,
       "then": {"add_keyword": "umami", "keyword_stacks": 2},
       "else": {"add_keyword": "umami", "keyword_stacks": 1}
     }
   }]
   ```
   **设计理念**：饺子是团圆菜，相邻菜品≥2时效果翻倍

2. **xiaolongbao（小笼包）** - Tier 0
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "delayed_trigger": {
         "delay_ticks": 1,
         "effect": {"add_keyword": "umami", "keyword_stacks": 2}
       }
     }
   }]
   ```
   **设计理念**：小笼包需要蒸制，1回合后爆发鲜美

3. **baozi（包子）** - Tier 0
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "heal_prestige": 1,
       "add_keyword": "aftertaste", "keyword_stacks": 1
     }
   }]
   ```
   **设计理念**：包子是治愈食物，回复1声望+回味

4. **spring_rolls（春卷）** - Tier 1
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "chain_right": {
         "range": 1,
         "effect": {"reduce_cooldown": 0.5}
       }
     }
   }]
   ```
   **设计理念**：春卷是快手菜，激活后加速右侧菜品

### Washoku（和食）
5. **onigiri（饭团）** - Tier 0
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "if_position": "leftmost",
       "then": {"stat_bonus": {"flavor": 3}},
       "else": {"add_keyword": "umami", "keyword_stacks": 1}
     }
   }]
   ```
   **设计理念**：饭团是前菜，在最左侧时风味+3

6. **tamagoyaki（玉子烧）** - Tier 0
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "add_keyword": "plating", "keyword_stacks": 1,
       "if_adjacent_has_tag": "washoku",
       "then_bonus": {"add_keyword": "knife_work", "keyword_stacks": 1}
     }
   }]
   ```
   **设计理念**：玉子烧是精致菜品，相邻和食时额外+刀工

7. **edamame（毛豆）** - Tier 0
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "clear_env_keyword": "taste_fatigue", "stacks": 1,
       "grant_gold": 1
     }
   }]
   ```
   **设计理念**：毛豆是开胃小菜，清除疲劳+1金币

8. **tofu_dengaku（田乐豆腐）** - Tier 1
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "convert_keyword": {
         "from": "greasy",
         "to": "umami",
         "ratio": 1.0
       }
     }
   }]
   ```
   **设计理念**：豆腐吸油，将油腻转化为鲜美

### Yatai（夜市）
9. **takoyaki（章鱼烧）** - Tier 0
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "add_keyword": "char_aroma", "keyword_stacks": 1,
       "random_chance": 0.3,
       "on_success": {"add_keyword": "plating", "keyword_stacks": 1}
     }
   }]
   ```
   **设计理念**：章鱼烧有30%概率额外+摆盘（卖相好）

10. **yaki_imo（烤红薯）** - Tier 0
    ```gdscript
    "triggers": [{
      "event": "self_activate",
      "effect": {
        "accumulate": {
          "counter_id": "sweetness",
          "increment": 1,
          "threshold": 2,
          "on_threshold": {"add_keyword": "aftertaste", "keyword_stacks": 3, "reset_counter": true}
        }
      }
    }]
    ```
    **设计理念**：烤红薯越烤越甜，激活2次后爆发回味

11. **hashimaki（筷卷）** - Tier 0
    ```gdscript
    "triggers": [{
      "event": "self_activate",
      "effect": {
        "copy_adjacent_keyword": {
          "target": "left",
          "keyword": "any",
          "stacks": 1
        }
      }
    }]
    ```
    **设计理念**：筷卷是混合菜，复制左侧菜品的1层关键词

12. **taiyaki（鲷鱼烧）** - Tier 0
    ```gdscript
    "triggers": [{
      "event": "self_activate",
      "effect": {
        "if_keyword_gte": {"keyword": "char_aroma", "stacks": 2},
        "then": {"consume_keyword": "char_aroma", "per_stack_presentation_bonus": 3.0},
        "else": {"add_keyword": "char_aroma", "keyword_stacks": 1}
      }
    }]
    ```
    **设计理念**：鲷鱼烧是烤制甜点，焦香≥2时消耗转化为卖相

---

## Tier 0 同质化菜品差异化

### 夜市焦香四兄弟（都是 add_keyword char_aroma 1）
1. **yakitori（烤鸡串）** - 保持原样
2. **yaki_tomorokoshi（烤玉米）** - 改为：
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "add_keyword": "char_aroma", "keyword_stacks": 1,
       "chain_right": {"range": 1, "effect": {"add_keyword": "char_aroma", "keyword_stacks": 1}}
     }
   }]
   ```
   **设计理念**：烤玉米香气扩散，向右传播1层焦香

3. **ikayaki（烤鱿鱼）** - 改为：
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "add_keyword": "char_aroma", "keyword_stacks": 1,
       "if_adjacent_has_tag": "yatai",
       "then_bonus": {"reduce_cooldown_self": 0.3}
     }
   }]
   ```
   **设计理念**：鱿鱼快烤，相邻夜市菜时自身CD-0.3秒

4. **yaki_onigiri（烤饭团）** - 改为：
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "add_keyword": "char_aroma", "keyword_stacks": 1,
       "if_position": "leftmost",
       "then_bonus": {"add_keyword": "umami", "keyword_stacks": 1}
     }
   }]
   ```
   **设计理念**：烤饭团是前菜，最左侧时额外+鲜美

### 中华焦香三兄弟
1. **chahan（蛋炒饭）** - 保持原样
2. **scallion_pancake（葱油饼）** - 改为：
   ```gdscript
   "triggers": [{
     "event": "self_activate",
     "effect": {
       "add_keyword": "char_aroma", "keyword_stacks": 1,
       "delayed_trigger": {
         "delay_ticks": 1,
         "effect": {"clear_env_keyword": "greasy", "stacks": 1}
       }
     }
   }]
   ```
   **设计理念**：葱油饼1回合后清除油腻（葱解腻）

---

## 实现优先级

### Phase 1: 核心效果扩展（立即实现）
1. 延迟触发（delayed_trigger）
2. 连锁反应（chain_left/chain_right）
3. 条件爆发（if_then_else）
4. 位置依赖（if_position）
5. 累积充能（accumulate）

### Phase 2: 高级效果（后续实现）
6. 牺牲机制（sacrifice_self）
7. 复制效果（copy_adjacent_effect）
8. 转换关键词（convert_keyword）
9. 冷却操控（reduce_cooldown）
10. 随机效果（random_choice）

### Phase 3: 对抗效果（PvP专用）
11. 反弹机制（reflect_to_opponent）
12. 吸取效果（drain_opponent_keyword）

---

## 下一步
1. 扩展 TriggerSystem._execute_effect() 支持新效果类型
2. 更新菜系数据文件（Chuuka.gd, Washoku.gd, Yatai.gd）
3. 创建气泡商店UI（BubbleShop.gd + BubbleShop.tscn）
4. 创建事件弹窗UI（EventPopup.gd + EventPopup.tscn）
