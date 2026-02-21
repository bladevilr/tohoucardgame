# TouhouBazaar 战斗与数值系统（Showdown）完整说明

更新时间：2026-02-18  
适用代码：`E:\TouhouBazaar` 当前工作区（以代码行为为准）

核心实现文件：

- `core/GameManager.gd`
- `core/MatchState.gd`
- `core/PlayerState.gd`
- `systems/ShowdownManager.gd`
- `systems/ShowdownResolver.gd`
- `systems/KeywordManager.gd`
- `systems/TriggerSystem.gd`
- `systems/TechniqueManager.gd`
- `systems/SynergyManager.gd`
- `data/GameConfig.gd`
- `data/CuisineDatabase.gd`
- `ui/ShowdownView.gd`
- `ui/ResultScreen.gd`

---

## 1. 文档目标与适用范围

本文覆盖：

1. 日循环到对决的完整阶段流转。
2. Showdown 每个 Tick 的执行顺序与数学公式。
3. 单次上菜的完整分数管线（包含技法遗物、关键词、触发、评委、连动）。
4. 融合/羁绊/撞菜/声望结算的真实行为。
5. PvE 与 PvP 结算差异。
6. 回归测试清单与高风险改动点。

不覆盖：

1. 历史 `CombatManager/CombatResolver` 旧战斗链路（当前主流程不使用）。
2. 资源制作、美术流程、UI 美术规范。

---

## 2. 术语与四维属性

- `Flavor`（风味）：主得分属性，上菜直接给分。
- `Presentation`（卖相）：压制维度，通过 DoT 持续给分。
- `Technique`（技法）：全局倍率维度，放大得分。
- `Aroma`（香气）：节奏维度，减少冷却。
- `Tick`：对决固定步长，当前 `0.1s`。
- `Runtime`：对每道上场菜生成的运行态，含 `base_cd/current_cd/activate_count/tick_accum` 等。

---

## 3. 大循环与阶段状态机

### 3.1 每日 6 行动结构（当前主循环）

定义在 `core/GameManager.gd`：

1. `EVENT_CHOICE`：清晨奇遇（`morning_event`）
2. `EVENT_CHOICE`：早市传闻（`market_rumor`）
3. `PVE_BATTLE`：午间试营业（`noon_trial`）
4. `EVENT_CHOICE`：下午茶歇（`afternoon_tea`）
5. `EVENT_CHOICE`：黄昏暗盘（`dusk_market`）
6. `PVP_BATTLE`：深夜料理对决（`midnight_showdown`）

### 3.2 阶段推进规则

`GameManager.advance_phase()` 关键分支：

- `SHOP` -> 进入下一行动（`_advance_to_next_action`）
- `EVENT_CHOICE` -> 回 `SHOP`
- `PVE_BATTLE` -> `PREP`（并标记 `_is_pve_showdown = true`）
- `PREP` -> `SHOWDOWN`
- `SHOWDOWN`:
  - 若来自 PvE：回 `SHOP`
  - 否则（PvP）：`_end_day()`

### 3.3 结算入口

`ShowdownView` 在 `_ready()` 中调用：

`ShowdownManager.start_showdown(match_state)`

---

## 4. Showdown 运行框架

### 4.1 管理层（ShowdownManager）职责

- 创建并持有 `ShowdownResolver`。
- 在 `_process(delta)` 中按固定步长 `0.1` 推进 `resolver.tick(0.1)`。
- 对决结束时：
  - 将 `resolver.get_analysis_data()` 写入 `match_state.meta["showdown_analysis"]`。
  - 判定胜负并执行 PvE/PvP 对应结算。

### 4.2 PvE / PvP 结算差异（非常关键）

在 `systems/ShowdownManager.gd`：

- 判断条件：
  - `is_pve = (match_state.current_action_data.phase == "PVE_BATTLE")`
- `PvE`：
  - 失败不扣声望。
  - 若玩家胜利，按 `current_encounter.reward_gold` 给金币。
- `PvP`：
  - 败方调用 `match_state.apply_prestige_damage(loser, score_diff)`。
  - 更新胜负场与连胜/连败。
  - 胜者获得 `GameConfig.WIN_BONUS_GOLD`。

---

## 5. Resolver 初始化（`ShowdownResolver.setup()`）

执行顺序：

1. `match_state.reset_for_showdown()`：重置双方关键词与环境状态。
2. 重置内部缓存：
   - `_scores`
   - `_serve_log`
   - `_broadcast_log`
   - `_highlight_moments`
   - `_cuisine_scores`
   - `_item_cumulative_scores`
   - `_clash_penalties`
   - `_dot_totals`
3. 重置融合状态：
   - `_active_fusions`
   - `_fusion_presentation_mults`
   - `_fusion_all_attr_bonus`
   - `KeywordManager.reset_fusion_multipliers()`
4. 为双方构建菜品运行时列表 `_item_runtimes[p]`。
5. 预计算玩家全局倍率：
   - `TechniqueMult`
   - `AromaReduction`
   - `PresentationTotal`
6. 触发全局事件：
   - `showdown_start`
   - `SignalBus.showdown_started`

---

## 6. 每 Tick 执行顺序（核心）

每个 Tick 对双方、每道 runtime 菜执行：

1. `KeywordManager.apply_spotlight()`：若有 `spotlight` 层数，直接减当前 CD 并消耗。
2. `_process_item_tick_triggers()`：处理 `on_tick` 的间隔累积触发。
3. 冷却推进：`runtime.current_cd -= effective_tick`。
4. 若 `current_cd <= 0`：触发 `_activate_item()`。
5. 激活后重置冷却为 `new_cd`。
6. 双方菜处理完后，结算卖相压制 DoT（`_apply_presentation_dot`）。
7. 发出 `SignalBus.showdown_tick`。

---

## 7. 关键公式（以当前代码值为准）

### 7.1 技法倍率

来源：`data/GameConfig.gd`

```text
TechniqueMult = 1.0 + total_technique * 0.02
```

参数：

- `TECHNIQUE_MULT_BASE = 1.0`
- `TECHNIQUE_MULT_PER_POINT = 0.02`

### 7.2 香气减冷却

```text
AromaReduction = min(floor(total_aroma / 10) * 0.05, 0.35)
```

参数：

- `AROMA_CD_REDUCTION_PER_10 = 0.05`
- `AROMA_CD_REDUCTION_CAP = 0.35`

### 7.3 Tick 冷却推进

```text
cd_reduction_mult = 1.0 - AromaReduction
effective_tick = delta / max(0.1, cd_reduction_mult)
current_cd -= effective_tick
```

激活后重置：

```text
new_cd = base_cd * (1.0 - AromaReduction) + env_cd_penalty
current_cd = max(0.5, new_cd)
```

其中：

```text
env_cd_penalty = dull_stacks * 0.3
```

### 7.4 卖相压制 DoT

```text
diff = PresentationTotal[0] - PresentationTotal[1]
if abs(diff) < 0.01: no dot
else:
  winner = sign(diff)
  dot = abs(diff) * PRESENTATION_DOT_COEFF * TechniqueMult[winner] * delta * judge_dot_mult_product
```

参数：

- `PRESENTATION_DOT_COEFF = 0.6`

### 7.5 声望伤害（PvP）

`MatchState.apply_prestige_damage()` 调用：

```text
damage = 2 + floor(score_diff / 80) * 1
```

参数：

- `PRESTIGE_DAMAGE_BASE = 2`
- `PRESTIGE_DIFF_DIVISOR = 80.0`
- `PRESTIGE_DAMAGE_PER_DIFF = 1`

---

## 8. 单次上菜计分管线（`_activate_item`）

以下顺序会直接影响最终分数：

1. 读取 `item.base_stats`。
2. 应用“技法遗物全局修正”：
   - `TechniqueManager.apply_global_modifiers_to_stats(player, item, base_scores)`。
3. 应用厨师被动修正（当前包含美铃、爱丽丝、正邪等）。
4. 兼容旧附魔字段 `item.enchant`：若有，按 `TechniqueDatabase` 再叠加一次修正。
5. 应用融合全属性加成（`_fusion_all_attr_bonus`）。
6. 应用融合激活型效果（例如夜市首次激活倍率）。
7. 进入关键词系统：
   - `KeywordManager.apply_keyword_modifiers(player_idx, base_scores)`。
8. 处理标签直接效果：
   - `rich`：加环境 `greasy`，并乘风味 1.2。
   - `light`：清除环境 `greasy` 与 `taste_fatigue`。
9. 执行触发系统：
   - `SignalBus.item_activated`
   - `TriggerSystem.process_event("item_activated", context)`
   - 执行 `item.on_activate[]`
   - 执行协同关键词触发（`_process_synergy_keyword_triggers`）
   - 执行融合运行时触发（`_process_fusion_runtime_triggers`）
10. 把触发写入的 `score_bonus` 叠到 `modified_scores`。
11. 取 `flavor` 作为本次直接上菜得分并乘：
   - 玩家 `TechniqueMult`
   - 全评委 `flavor_mult` 乘区
12. 应用妖梦小菜随机双倍（命中时 `x2.0`）。
13. `max(0, flavor)` 后写入：
   - `_scores[player_idx]`
   - `_item_cumulative_scores`
   - `_serve_log`
   - `_cuisine_scores`（融合标签菜不计入撞菜）

---

## 9. 关键词系统细节（KeywordManager）

### 9.1 玩家增益关键词

- `umami`：`flavor + 3 * stacks`
- `char_aroma`：`flavor + 2 * stacks`
- `plating`：`presentation + 3 * stacks`
- `knife_work`：`technique + 2 * stacks`
- `aftertaste`：
  - `flavor *= 1 + stacks * (0.30 * fusion_multiplier)`
- `secret_recipe`：
  - `flavor *= 1 + stacks * (0.50 * fusion_multiplier)`
  - 结算后会消费（`consume_keyword("secret_recipe")`）
- `spotlight`：
  - 每层减 `1.0` 当前 CD，并消费

### 9.2 共享环境关键词

- `greasy`：`flavor -= 2 * stacks`
- `messy`：`presentation -= 2 * stacks`
- `taste_fatigue`：`flavor *= max(0.1, 1 - 0.15 * stacks)`
- `dull`：仅作用于冷却惩罚（`+0.3s * stacks`）

### 9.3 融合关键词倍率隔离

`_fusion_multipliers` 结构为 `[{}, {}]`，按玩家索引隔离；避免 A 玩家融合效果污染 B 玩家关键词倍率。

---

## 10. 技法遗物系统（TechniqueManager）

### 10.1 定位

当前“技法”是遗物栏机制，不占棋盘格。

- 上限：`MAX_TECHNIQUE_SLOTS = 4`
- 装备 API：`equip_technique(player, technique)`

### 10.2 生效范围

对每道菜按匹配条件计算全局修正：

- 菜系匹配（含映射）：
  - `chinese -> chuuka`
  - `japanese -> washoku`
  - `french -> youshoku`
  - `wild -> yatai`
  - `dessert -> kanmi`
  - `molecular -> yakuzen`
- 可附加 `restrictions`（tag 条件）
- 可提供：
  - `flavor/presentation/technique/aroma` 乘法加成
  - `cd_modifier`
  - `added_tags`

### 10.3 与旧附魔兼容

`ShowdownResolver` 同时保留旧 `item.enchant` 路径：

- 冷却层：`base_cd += legacy_tech.cd_modifier`
- 属性层：按 legacy `modifiers` 继续乘法

这意味着旧数据仍可跑通，且与遗物机制并存。

---

## 11. 触发系统协议（TriggerSystem）

### 11.1 事件归一化

支持旧新事件 ID 映射，例如：

- `item_activated` -> `self_activate`
- `on_self_activate` / `when_this_activates` -> `self_activate`
- `on_activate` -> `any_activate`
- `on_tick` -> `item_tick`
- `on_first_activate` -> `self_first_activate`

### 11.2 条件系统

支持：

- 字符串条件：
  - `always`
  - `has_tag:<tag>`
  - `cuisine:<id>`
  - `size:<n>`
  - `keyword:<kw>`
  - `adjacent_<cuisine>` 等
- 字典条件：
  - `adjacent_has_all_tags`
  - `adjacent_has_id`
  - `for_each_size` / `for_each_tag` / `for_each_left`
  - `if_position`（leftmost/rightmost）
  - `if_count_size`

### 11.3 效果系统

支持“新 schema + 旧 schema + 字符串 effect”的兼容执行。

典型支持：

- 直接属性：`flavor/presentation/technique/aroma`
- 关键词增减：`add_keyword`, `consume_keyword`
- 环境增减：`add_environment`, `clear_environment`
- 倍率型：`flavor_mult`, `presentation_mult`
- 首次触发：`first_activate_bonus`
- per-count 扩展：`per_count_bonus`

链式保护：

- `_max_chain_depth = GameConfig.MAX_CHAIN_DEPTH`（当前 10）

---

## 12. 羁绊、融合与协同

### 12.1 两套来源的关系

当前存在两套“羁绊/融合”来源：

1. `CuisineDatabase`：
   - 菜系 3 件套 synergy
   - 指定菜系组合 fusion
2. `SynergyManager`：
   - 额外规则（如 small_army/double_large 等）

### 12.2 Resolver 中的实际消费路径

- `CuisineDatabase` synergy/fusion：
  - 在 `setup()` 中加入 `_active_fusions`，用于静态数值与融合运行时触发。
- `SynergyManager.check_synergies(player)`：
  - 结果存 `_player_synergies`，主要用于 `keyword_trigger`。

注意：`SynergyManager` 中很多 `effect` 字段并不直接进入 Resolver 的静态数值阶段；当前主要依赖其 `keyword_trigger`。

### 12.3 典型融合运行时效果（Resolver 内硬编码消费）

- 焦香转鲜美（夜市+和食）
- 清淡菜触发环境净化并加风味（和食+药膳）
- 夜市菜随机关键词增益（夜市+药膳）
- 回味转秘方（甜品+药膳）

---

## 13. 撞菜机制（Cuisine Clash）

执行时机：`_finish()` 里先执行 `_apply_cuisine_clash()`。

规则：

1. 仅当双方都存在同菜系且为非 `fusion` 标签菜时参与。
2. 比较该菜系累计风味 `_cuisine_scores[p][cuisine]`。
3. 低分方扣分：

```text
penalty = loser_cuisine_score * (1 - CLASH_LOSER_SCORE_MULT)
```

当前 `CLASH_LOSER_SCORE_MULT = 0.5`，即失败方该菜系有效得分只保留 50%。

结果写入 `_clash_penalties` 并在结果页展示。

---

## 14. 评委修正

两个入口：

1. `flavor_mult`：在 `_activate_item` 中对每次上菜风味乘法生效。
2. `dot_mult`：在 `_apply_presentation_dot` 中对卖相 DoT 生效。

额外特例：

- `eiki`（四季映姬）在 `_finish()` 中有“接近平局时双方同增 1.3x”的终局裁定。

---

## 15. 结果页（ResultScreen）字段来源

`ShowdownResolver.get_analysis_data()` 输出：

```gdscript
{
	"scores": [float, float],
	"technique_mults": [float, float],
	"aroma_reductions": [float, float],
	"presentation_totals": [float, float],
	"dot_totals": [float, float],
	"item_contributions": [{slot_idx: {name, total_score}}, {...}],
	"clash_penalties": [{cuisine, loser_idx, penalty}],
	"player_synergies": [Array, Array],
	"serve_log": Array
}
```

结果页会：

1. 展示双方总分。
2. 展示我方菜品贡献排行。
3. 展示撞菜惩罚明细。
4. 根据评委修正与得分结构生成动态评论。

---

## 16. 当前关键常量总表（以代码为准）

| 常量 | 当前值 | 文件 | 说明 |
| --- | --- | --- | --- |
| `SHOWDOWN_DURATION` | `30.0` | `data/GameConfig.gd` | 对决时长 |
| `TICK_INTERVAL` | `0.1` | `data/GameConfig.gd` | Tick 步长 |
| `PRESENTATION_DOT_COEFF` | `0.6` | `data/GameConfig.gd` | 卖相 DoT 系数 |
| `TECHNIQUE_MULT_PER_POINT` | `0.02` | `data/GameConfig.gd` | 技法每点倍率增量 |
| `AROMA_CD_REDUCTION_PER_10` | `0.05` | `data/GameConfig.gd` | 每 10 香气减冷却 |
| `AROMA_CD_REDUCTION_CAP` | `0.35` | `data/GameConfig.gd` | 香气减冷却上限 |
| `SPOTLIGHT_CD_PER_STACK` | `1.0` | `data/GameConfig.gd` | 聚光每层减 CD |
| `DULL_CD_PENALTY` | `0.3` | `data/GameConfig.gd` | 沉闷每层 CD 惩罚 |
| `CLASH_LOSER_SCORE_MULT` | `0.5` | `data/GameConfig.gd` | 撞菜失败方保留比例 |
| `PRESTIGE_DAMAGE_BASE` | `2` | `data/GameConfig.gd` | PvP 声望基础伤害 |
| `PRESTIGE_DIFF_DIVISOR` | `80.0` | `data/GameConfig.gd` | 分差步进除数 |
| `PRESTIGE_DAMAGE_PER_DIFF` | `1` | `data/GameConfig.gd` | 每步进增加伤害 |

---

## 17. 平衡调参抓手（建议按优先级）

### 17.1 先调“节奏”

优先参数：

- `SHOWDOWN_DURATION`
- `AROMA_CD_REDUCTION_CAP`
- 菜品 `cooldown` 分布

目标：每局有效上菜次数落在可读区间，避免“前 10 秒无反馈”或“后 10 秒刷屏”。

### 17.2 再调“得分结构”

优先参数：

- `PRESENTATION_DOT_COEFF`
- 关键词强度（尤其 `aftertaste/secret_recipe`）

目标：风味爆发与卖相压制都能赢，避免单一路径统治。

### 17.3 最后调“失败惩罚”

优先参数：

- `PRESTIGE_DAMAGE_BASE`
- `PRESTIGE_DIFF_DIVISOR`

目标：失败有压力，但不要让 1~2 次失误直接滚崩。

---

## 18. 回归验证清单（建议每次改动后执行）

### 18.1 编译与加载

1. `--headless --path ... --quit` 无 `SCRIPT ERROR/Parse Error`。
2. 主场景链路（MainMenu/CharacterSelect/GameBoard/Encounter/Showdown/Result）可加载。

### 18.2 数值一致性

1. 技法倍率随总技法线性增长：`+50 技法` 应等价 `+1.0` 倍率。
2. 香气减冷却在 35% 处封顶。
3. DoT 只由卖相差触发，不受风味直接值影响。

### 18.3 机制正确性

1. PvE 失败不扣声望。
2. PvP 才更新 wins/losses/streak。
3. 撞菜只计算非融合菜。
4. `secret_recipe` 使用后应被消费。
5. `spotlight` 每层只消费一次且即时减 CD。

### 18.4 兼容层回归

1. 旧 `item.enchant` 仍生效。
2. `TriggerSystem` 旧事件名映射可触发。
3. `add_env_keyword` / `clear_env_keyword` 旧字段可运行。

---

## 19. 开发约束（避免再次出现“能跑但脚本加载失败”）

当前项目对 GDScript 采取较严格策略：部分“类型推断为 Variant”的警告会被当成错误处理。

建议：

1. 对 `dict.get()` 返回值，优先显式类型：
   - `var x: Dictionary = ...`
   - `var s: String = str(...)`
   - `var b: bool = ...`
2. 避免在关键脚本中大量使用 `:=` 接受 Variant 推断。
3. 提交前至少做一次 headless 启动检查。

---

## 20. 结论

当前 Showdown 系统已形成“可维护、可调参、可解释”的完整闭环：

- 阶段流转明确（含 PvE/PvP 差异）。
- Tick 执行顺序稳定且公式清晰。
- 分析数据与结果页能对齐关键机制。
- 旧数据兼容层仍可运行。

后续若要继续深化，优先方向是：

1. 将 `SynergyManager.effect` 中未被 Resolver 消费的字段统一接入。
2. 将 ResultScreen 的“分数拆解”升级为与 resolver 同步的逐乘区日志重建（而非近似拆解）。
3. 为 PvE 追加“难度曲线可视化”与自动平衡回归脚本。