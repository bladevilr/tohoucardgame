# 东方料理对决 — 项目全览文档

更新时间：2026-02-18
适用代码：`E:\TouhouBazaar` 当前工作区

---

## 1. 基本信息

| 项目属性 | 详情 |
|---------|------|
| **项目名称** | 东方料理对决 (Touhou Cooking Showdown) |
| **引擎** | Godot 4.6 (Forward Plus) |
| **分辨率** | 1920×1080, Stretch Mode = canvas_items |
| **语言** | GDScript |
| **类型** | 自走棋/料理竞技评分制（对标 The Bazaar） |
| **字体** | NotoSansSC (Regular + Bold) |
| **主题** | `themes/default_theme.tres` |
| **入口场景** | `ui/MainMenu.tscn` |

---

## 2. 项目结构

```
TouhouBazaar/
├── core/                       # 核心框架
│   ├── GameManager.gd          # 游戏主循环 (每日6行动结构)
│   ├── MatchState.gd           # 比赛状态 (1v1淘汰赛制)
│   ├── PlayerState.gd          # 玩家状态 (声望/板面/背包/关键词栈)
│   ├── SignalBus.gd            # 全局信号总线
│   └── resources/              # 8个Resource数据类
│       ├── ChefData.gd
│       ├── DishData.gd
│       ├── EncounterData.gd
│       ├── EventData.gd
│       ├── IngredientData.gd
│       ├── JudgeData.gd
│       ├── TechniqueData.gd
│       └── ToolData.gd
│
├── data/                       # 数据库层
│   ├── GameConfig.gd           # 全局配置常量 (246行)
│   ├── DishDatabase.gd         # 菜品数据库 → 加载6个菜系池
│   ├── ChefDatabase.gd         # 10位厨师数据
│   ├── JudgeDatabase.gd        # 12位评委数据
│   ├── CuisineDatabase.gd      # 6菜系定义 + Synergy + Fusion
│   ├── KeywordDatabase.gd      # 7增益+4环境减益+4标记关键词
│   ├── TechniqueDatabase.gd    # 15种烹饪手法
│   ├── ToolDatabase.gd         # 20+厨具
│   ├── IngredientDatabase.gd   # 食材库 (4阶约30种)
│   ├── CraftingDatabase.gd     # 合成配方
│   ├── EffectDatabase.gd       # 效果模板库
│   ├── ArtDatabase.gd          # 美术资源映射与加载
│   └── cuisines/               # 6个菜系菜品数据池
│       ├── Washoku.gd          # 和食 (~20道)
│       ├── Chuuka.gd           # 中华料理 (~20道)
│       ├── Youshoku.gd         # 洋食/法餐 (~18道)
│       ├── Yatai.gd            # 屋台/野味 (~21道)
│       ├── Kanmi.gd            # 甘味/甜品 (~20道)
│       └── Yakuzen.gd          # 药膳/分子 (~20道)
│
├── systems/                    # 系统逻辑层
│   ├── ShowdownResolver.gd     # ★核心★ CD驱动实时评分引擎 (809行)
│   ├── ShowdownManager.gd      # 对决编排 + 结算 + PvE/PvP分支
│   ├── TriggerSystem.gd        # ★核心★ 事件驱动触发引擎 (638行)
│   ├── EncounterManager.gd     # 切磋/事件系统 (29KB, 含PvE对手生成)
│   ├── BoardManager.gd         # 10格板面管理 + 位置关系API
│   ├── ShopManager.gd          # 多商人商店系统
│   ├── KeywordManager.gd       # 关键词栈管理 (叠加/消耗/清除)
│   ├── SynergyManager.gd       # Synergy检测 (标签/菜系/做法)
│   ├── TechniqueManager.gd     # 手法附魔系统 (遗物栏机制)
│   ├── CraftingManager.gd      # 多层合成系统
│   ├── IngredientManager.gd    # 食材管理 (附加到菜品)
│   ├── EventSystem.gd          # 随机事件系统
│   ├── VFXManager.gd           # 视觉特效管理
│   ├── CombatManager.gd        # (legacy) 旧战斗管理
│   └── CombatResolver.gd       # (legacy) 旧战斗解算
│
├── ui/                         # UI层
│   ├── MainMenu.gd/.tscn       # 主菜单
│   ├── CharacterSelect.gd/.tscn # 厨师选择 (9/10宫格角色卡)
│   ├── GameBoard.gd/.tscn      # ★主界面★ 备菜阶段 (657行)
│   ├── ShowdownView.gd/.tscn   # 对决演出
│   ├── ResultScreen.gd/.tscn   # 结算 (分数拆解+评委点评)
│   ├── EncounterView.gd/.tscn  # 事件/切磋界面
│   ├── CombatView.gd/.tscn     # (legacy)
│   ├── TutorialOverlay.gd/.tscn # 教学引导
│   ├── UIHelper.gd             # UI工具函数 (15KB)
│   ├── components/             # 21个UI组件
│   │   ├── ItemCard.gd/.tscn           # 物品卡牌 (CD条/品阶/关键词)
│   │   ├── BoardSlot.gd/.tscn          # 板面格子 (拖放/占位)
│   │   ├── ScoreBar.gd/.tscn           # 分数对比条
│   │   ├── SynergyPanel.gd/.tscn       # Synergy面板
│   │   ├── JudgePanel.gd/.tscn         # 评委面板
│   │   ├── ItemTooltip.gd/.tscn        # 物品详情悬浮
│   │   ├── KeywordTooltip.gd/.tscn     # 关键词提示
│   │   ├── BackpackDrawer.gd/.tscn     # 背包抽屉
│   │   ├── PhaseBanner.gd/.tscn        # 阶段横幅
│   │   ├── HelpPanel.gd               # 帮助面板
│   │   ├── ShopPanel.gd               # 商店面板
│   │   ├── PlayerHUD.gd               # 玩家HUD
│   │   ├── OpponentBar.gd             # 对手信息栏
│   │   ├── StatsPanel.gd              # 属性面板
│   │   ├── BoardPanel.gd              # 棋盘面板
│   │   └── CardTooltip.gd             # 卡牌提示
│   ├── effects/                # 12个效果脚本
│   │   ├── UIAnimations.gd     # UI动画系统
│   │   ├── UIColors.gd         # 颜色主题
│   │   ├── SceneTransition.gd  # 场景过渡
│   │   ├── ParticleFactory.gd  # 粒子工厂
│   │   ├── ScreenFX.gd         # 全屏特效
│   │   ├── AudioBridge.gd      # 音频桥接
│   │   ├── DragManager.gd      # 拖拽管理
│   │   ├── FloatingText.gd     # 浮动文字
│   │   ├── AdjacencyVisualizer.gd # 相邻可视化
│   │   ├── DishProjectile.gd/.tscn # 菜品投射物
│   │   └── JudgeAvatar.gd/.tscn    # 评委头像
│   ├── shaders/                # 13个着色器
│   │   ├── card_material.gdshader      # 卡牌材质 (3KB, 最复杂)
│   │   ├── board_surface.gdshader      # 板面表面
│   │   ├── card_holographic.gdshader   # 全息卡牌
│   │   ├── card_glow.gdshader          # 卡牌发光
│   │   ├── card_idle_shimmer.gdshader  # 卡牌待机闪烁
│   │   ├── card_frame.gdshader         # 卡牌边框
│   │   ├── presentation_war.gdshader   # 卖相战特效
│   │   ├── dissolve_transition.gdshader # 溶解过渡
│   │   ├── background_gradient.gdshader # 背景渐变
│   │   ├── environment_overlay.gdshader # 环境覆盖
│   │   ├── mat_pattern.gdshader        # 垫布花纹
│   │   ├── score_bar_fill.gdshader     # 分数条填充
│   │   └── slot_pulse.gdshader         # 格子脉冲
│   └── views/
│       └── CardInspector.gd/.tscn      # 卡牌详情检视 (18KB)
│
├── ai/                         # AI系统
│   ├── AIController.gd         # AI控制器 (商店+备菜+策略)
│   ├── AIStrategy.gd           # AI策略基类
│   └── strategies/             # 7种AI策略
│       ├── AIAggressive.gd     # 攻击型
│       ├── AIBalanced.gd       # 平衡型
│       ├── AIDefensive.gd      # 防御型
│       ├── AIEconomic.gd       # 经济型
│       ├── AIRandom.gd         # 随机型
│       ├── AISpeedster.gd      # 速攻型
│       └── AISpiritRush.gd     # 灵力冲击型
│
├── assets/                     # 美术资源
│   ├── ui/
│   │   ├── dishes/             # 159张菜品图 (~1.5-2MB/张)
│   │   ├── chefs/              # 9张厨师立绘 (缺seija)
│   │   ├── judges/             # 评委图 (大量缺失, 见资源清单)
│   │   ├── backgrounds/        # 3张背景 (main_menu, gameplay, gameplay_v2)
│   │   ├── cards/              # 5张卡牌框架 (back, base, bg_texture, frame, frame_green)
│   │   └── theme/              # 6张UI主题 (button×3, panel×2, hover)
│   └── textures/               # 材质纹理
│       ├── card_base_metal.png
│       ├── card_frame_mask.png
│       ├── table_wood_diffuse.png
│       ├── table_wood_normal.png
│       └── environment/
│
├── tools/                      # 开发/测试工具
│   ├── HeadlessSimulator.gd    # 无头模拟器 (自动跑完整对局)
│   ├── CuisineBalanceTest.gd   # 菜系平衡测试
│   ├── CardPowerRanker.gd      # 卡牌强度排名
│   ├── EconomyAnalyzer.gd      # 经济分析器
│   ├── EncounterCalibrator.gd  # 遭遇校准器
│   ├── BalanceRunner.gd        # 平衡跑批
│   ├── AssetGenerator.gd       # 资源生成器
│   ├── TextureGenerator.gd     # 纹理生成器
│   ├── fix_assets.py           # 资源修复脚本
│   ├── fix_pngs.ps1            # PNG修复
│   ├── process_assets_magick.ps1 # ImageMagick处理
│   └── trim_assets.ps1         # 资源裁剪
│
├── themes/
│   └── default_theme.tres      # 全局UI主题
│
├── docs/                       # 文档
│   ├── PROJECT_OVERVIEW.md     # ← 本文档
│   ├── COMBAT_AND_NUMERICAL_SYSTEM.md # 战斗与数值系统完整说明
│   └── new.md
│
├── debug/                      # 调试输出
│
├── DESIGN_DOC.md               # 核心设计文档 (67KB, 1306行)
├── PLAN.md                     # 实施计划 (22KB)
├── GAME_DATA_SPEC.md           # 游戏数据规格
├── UI_UPGRADE_SPEC.md          # UI升级规格 (70KB)
├── BATTLE_CLARITY_SPEC.md      # 战斗清晰度规格
├── ASSET_CHECKLIST.md          # 资源清单
├── GLOSSARY.md                 # 术语表
└── project.godot               # Godot项目配置
```

---

## 3. Autoload 单例 (27个)

按加载顺序：

| 分类 | Autoload | 文件 |
|------|----------|------|
| **信号** | SignalBus | `core/SignalBus.gd` |
| **配置** | GameConfig | `data/GameConfig.gd` |
| **数据库** | DishDatabase | `data/DishDatabase.gd` |
| | KeywordDatabase | `data/KeywordDatabase.gd` |
| | TechniqueDatabase | `data/TechniqueDatabase.gd` |
| | ToolDatabase | `data/ToolDatabase.gd` |
| | ChefDatabase | `data/ChefDatabase.gd` |
| | JudgeDatabase | `data/JudgeDatabase.gd` |
| | CuisineDatabase | `data/CuisineDatabase.gd` |
| | ArtDatabase | `data/ArtDatabase.gd` |
| | CraftingDatabase | `data/CraftingDatabase.gd` |
| | IngredientDatabase | `data/IngredientDatabase.gd` |
| **核心** | GameManager | `core/GameManager.gd` |
| **系统** | IngredientManager | `systems/IngredientManager.gd` |
| | BoardManager | `systems/BoardManager.gd` |
| | ShopManager | `systems/ShopManager.gd` |
| | ShowdownManager | `systems/ShowdownManager.gd` |
| | SynergyManager | `systems/SynergyManager.gd` |
| | TechniqueManager | `systems/TechniqueManager.gd` |
| | CraftingManager | `systems/CraftingManager.gd` |
| | EncounterManager | `systems/EncounterManager.gd` |
| **UI效果** | UIAnimations | `ui/effects/UIAnimations.gd` |
| | SceneTransition | `ui/effects/SceneTransition.gd` |
| | ParticleFactory | `ui/effects/ParticleFactory.gd` |
| | UIColors | `ui/effects/UIColors.gd` |
| | ScreenFX | `ui/effects/ScreenFX.gd` |
| | AudioBridge | `ui/effects/AudioBridge.gd` |

---

## 4. 核心玩法机制

### 4.1 游戏流程

```
每日6行动循环:
  ① 清晨奇遇 (EVENT_CHOICE) → 回到商店
  ② 早市传闻 (EVENT_CHOICE) → 回到商店
  ③ 午间试营业 (PVE_BATTLE) → 备菜 → 对决 → 回到商店
  ④ 下午茶歇 (EVENT_CHOICE) → 回到商店
  ⑤ 黄昏暗盘 (EVENT_CHOICE) → 回到商店
  ⑥ 深夜料理对决 (PVP_BATTLE) → 备菜 → 对决 → 结算 → 进入下一天
```

- 每天PvE不扣声望，PvP失败扣声望
- 声望归零淘汰，赢满10场通关

### 4.2 四维属性体系

| 属性 | 作用 | 计算公式 |
|------|------|----------|
| **味道(Flavor)** | 核心产分 | 上菜直接产分 |
| **卖相(Presentation)** | DoT压制 | `max(0, 我方-对方) × 0.6 / 秒` |
| **技法(Technique)** | 全局乘区 | `1.0 + tech × 0.02` |
| **香气(Aroma)** | CD加速 | 每10点-5%, 上限-35% |

### 4.3 对决(Showdown)引擎

- 时长: 30秒, Tick间隔: 0.1秒
- 菜品按各自CD自动上菜
- 上菜时执行 `on_activate` 效果 → 触发链式事件
- 实时分数累积，含卖相DoT
- 结束后撞菜惩罚 → 评委加权 → 最终结算

### 4.4 关键词系统

**增益 (作用于自身):**
| 关键词 | 效果 |
|--------|------|
| 鲜美(umami) | 每层下次味道+3 |
| 焦香(char_aroma) | 蓄力，消耗时每层味道+5 |
| 摆盘(plating) | 每层卖相+3 |
| 刀工(knife_work) | 每层技法+2 |
| 瞩目(spotlight) | 直接减CD |
| 回味(aftertaste) | 上菜后额外产出30%分数 |
| 秘方(secret_recipe) | 下次上菜味道×1.5 |

**环境减益 (影响双方):**
| 关键词 | 效果 |
|--------|------|
| 油腻(greasy) | 每层所有菜品味道-2 |
| 杂乱(messy) | 每层所有菜品卖相-2 |
| 味觉疲劳(taste_fatigue) | 味道产出-15% |
| 沉闷(dull) | 每层所有菜品CD+0.3s |

### 4.5 六大菜系

| 菜系ID | 中文名 | 定位 | 强势属性 | 菜品数据文件 |
|--------|--------|------|----------|-------------|
| `washoku` | 和食 | 鲜味刀工 | 技法/香气 | `data/cuisines/Washoku.gd` |
| `chuuka` | 中华 | 猛火锅气 | 味道/香气 | `data/cuisines/Chuuka.gd` |
| `youshoku` | 洋食 | 精致法餐 | 卖相/技法 | `data/cuisines/Youshoku.gd` |
| `yatai` | 屋台 | 野性盛宴 | 味道++ | `data/cuisines/Yatai.gd` |
| `kanmi` | 甘味 | 甜品收尾 | 卖相 | `data/cuisines/Kanmi.gd` |
| `yakuzen` | 药膳 | 科学养生 | 卖相/技法 | `data/cuisines/Yakuzen.gd` |

### 4.6 Synergy与Fusion

- 同菜系×3 → 菜系专精Synergy
- Fusion组合 (中+法→东西合璧, 日+分子→未来和食, 等)
- ≥4种不同菜系 → 万国料理博览
- 撞菜: 双方同菜系时直接PK，败方扣分

---

## 5. 角色数据

### 5.1 厨师 (10位)

| ID | 角色 | 专精菜系 | 被动技能 | 厨具栏位 |
|----|------|----------|----------|---------|
| `mystia` | 米斯蒂娅 | 屋台/和食 | 夜雀食堂: 夜市CD-15% | 3 |
| `sakuya` | 十六夜咲夜 | 洋食/甘味 | 时停备菜: 开局CD-1s | 3 |
| `youmu` | 魂魄妖梦 | 和食/洋食 | 二刀流: 小菜30%再次触发 | 3 |
| `meiling` | 红美铃 | 中华/屋台 | 气功调味: 焦香收益+30% | 3 |
| `marisa` | 雾雨魔理沙 | 屋台/药膳 | 魔法实验: 20%随机关键词 | 3 |
| `reimu` | 博丽灵梦 | 和食/药膳 | 巫女直觉: 每天首次刷新免费 | 3 |
| `alice` | 爱丽丝 | 洋食/甘味 | 人偶操演: 摆盘+30%, 厨具+1 | 4 |
| `patchouli` | 帕秋莉 | 洋食/中华 | 五行调和: 五行循环属性+20% | 3 |
| `reisen` | 铃仙 | 甘味/药膳 | 狂气之瞳: 对手开局CD+1s | 3 |
| `seija` | 鬼人正邪 | 中华/和食 | 天邪鬼翻转: 最高最低属性互换 | 3 |

### 5.2 评委 (12位)

| ID | 角色 | 核心修正 | 特殊规则 |
|----|------|----------|----------|
| `yuyuko` | 西行寺幽幽子 | 味道×1.5 | 鲜美/焦香关键词+50% |
| `yuuma` | 饕餮尤魔 | 味道×1.2, 香气上限40% | 浓郁标签味道+15% |
| `eiki` | 四季映姬 | 技法×1.5 | 分差<10%双方+30% |
| `aya` | 射命丸文 | DoT×1.3 | 最高卖相菜味道+20% |
| `yukari` | 八雲紫 | 每日随机 | 随机属性×2.0/×0.5 |
| `yuuka` | 风见幽香 | DoT×1.5 | 碾压时DoT+25% |
| `tenshi` | 比那名居天子 | 味道×1.2, 技法×1.2 | 环境debuff+50% |
| `kokoro` | 秦心 | DoT×1.3 | Fusion菜卖相+25% |
| `remilia` | 蕾米莉亚 | 卖相×1.5 | 清淡-20%, 浓郁味道+20% |
| `iku` | 永江衣玖 | 香气×1.4 | 环境debuff减半, 菜系多样+5% |
| `miko` | 丰聪耳神子 | 全属性×1.1 | 精进+15%, 3+菜系+10% |
| `raiko` | 堀川雷鼓 | 全菜品CD-10% | 每次激活+2%全属性 |

---

## 6. 商店与经济

| 参数 | 数值 |
|------|------|
| 起始金币 | 10 |
| 起始声望 | 5 |
| 每天基础收入 | 5 + Day bonus (上限+7) |
| 连胜奖金 | 2连+1, 3连+2, 5连+4 |
| 连败补偿 | 3连+2, 5连+3 |
| 刷新商店 | 2金/次 |
| 出售物品 | 购买价×50% |
| 通关条件 | 赢满10场 |

### 商人类型

- 食材商人 (固定)
- 菜品商人 (固定)
- 技法商人 (固定)
- 厨具商人 (Day 2起)
- 黑市商人 (随机出现)

### 品阶概率 (随Day提升)

| Day | 铜 | 银 | 金 | 钻 |
|-----|-----|-----|-----|-----|
| 1~3 | 70% | 25% | 5% | 0% |
| 4~6 | 40% | 35% | 20% | 5% |
| 7~9 | 20% | 30% | 35% | 15% |
| 10+ | 10% | 25% | 35% | 30% |

---

## 7. 关键常量 (GameConfig.gd)

| 常量 | 值 | 说明 |
|------|-----|------|
| `SHOWDOWN_DURATION` | 30.0 | 对决时长(秒) |
| `TICK_INTERVAL` | 0.1 | Tick步长(秒) |
| `BOARD_SLOTS` | 10 | 板面格数 |
| `STARTING_PRESTIGE` | 5 | 初始声望 |
| `STARTING_GOLD` | 10 | 初始金币 |
| `WINS_TO_CLEAR` | 10 | 通关胜场 |
| `TECHNIQUE_MULT_PER_POINT` | 0.02 | 每点技法乘区 |
| `AROMA_CD_REDUCTION_PER_10` | 0.05 | 每10香气CD减 |
| `AROMA_CD_REDUCTION_CAP` | 0.35 | 香气加速上限 |
| `PRESENTATION_DOT_COEFF` | 0.6 | 卖相DoT系数 |
| `PRESTIGE_DAMAGE_BASE` | 2 | 声望伤害基础 |
| `PRESTIGE_DIFF_DIVISOR` | 80.0 | 声望分差除数 |
| `CLASH_LOSER_SCORE_MULT` | 0.5 | 撞菜惩罚系数 |
| `MAX_CHAIN_DEPTH` | 10 | 触发链最大深度 |
| `MAX_TECHNIQUE_SLOTS` | 4 | 手法栏位上限 |
| `MAX_INGREDIENTS_PER_DISH` | 2 | 每菜食材上限 |

---

## 8. 美术资源清单

### 8.1 厨师立绘 (`assets/ui/chefs/`)

| ID | 角色 | 状态 |
|----|------|------|
| `alice` | 爱丽丝 | ✅ |
| `marisa` | 魔理沙 | ✅ |
| `meiling` | 红美铃 | ✅ |
| `mystia` | 米斯蒂娅 | ✅ |
| `patchouli` | 帕秋莉 | ✅ |
| `reimu` | 灵梦 | ✅ |
| `reisen` | 铃仙 | ✅ |
| `sakuya` | 咲夜 | ✅ |
| `youmu` | 妖梦 | ✅ |
| `seija` | 鬼人正邪 | ❌ 缺失 |

### 8.2 评委立绘 (`assets/ui/judges/`)

| ID | 角色 | 状态 | 备注 |
|----|------|------|------|
| `yuyuko` | 西行寺幽幽子 | ✅ | 有多表情版本 |
| `yuuka` | 风见幽香 | ⚠️ | 文件名为kazami.png, 需改名 |
| `remilia` | 蕾米莉亚 | ✅ | |
| `yuuma` | 饕餮尤魔 | ❌ 缺失 | |
| `eiki` | 四季映姬 | ❌ 缺失 | |
| `aya` | 射命丸文 | ❌ 缺失 | |
| `yukari` | 八雲紫 | ❌ 缺失 | |
| `tenshi` | 比那名居天子 | ❌ 缺失 | |
| `kokoro` | 秦心 | ❌ 缺失 | |
| `iku` | 永江衣玖 | ❌ 缺失 | |
| `miko` | 丰聪耳神子 | ❌ 缺失 | |
| `raiko` | 堀川雷鼓 | ❌ 缺失 | |

### 8.3 菜品图标 (`assets/ui/dishes/`)

总计159张，覆盖率高。具体缺失需运行 `ArtDatabase.get_missing_dish_icons()` 动态检查。

### 8.4 其他资源

| 分类 | 路径 | 数量 | 状态 |
|------|------|------|------|
| 背景图 | `assets/ui/backgrounds/` | 3 | ✅ |
| 卡牌框架 | `assets/ui/cards/` | 5 | ✅ |
| UI主题 | `assets/ui/theme/` | 6 | ✅ |
| 材质纹理 | `assets/textures/` | 4+1dir | ✅ |
| 着色器 | `ui/shaders/` | 13 | ✅ |
| 字体 | `ui/fonts/` | 2 (Regular+Bold) | ✅ |

---

## 9. 场景 (.tscn) 清单

| 场景路径 | 说明 |
|---------|------|
| `ui/MainMenu.tscn` | 主菜单 |
| `ui/CharacterSelect.tscn` | 厨师选择 |
| `ui/GameBoard.tscn` | 备菜主界面 |
| `ui/ShowdownView.tscn` | 对决演出 |
| `ui/ResultScreen.tscn` | 结算屏幕 |
| `ui/EncounterView.tscn` | 事件/切磋 |
| `ui/CombatView.tscn` | (legacy) |
| `ui/TutorialOverlay.tscn` | 教学覆盖 |
| `ui/components/ItemCard.tscn` | 物品卡牌 |
| `ui/components/BoardSlot.tscn` | 板面格子 |
| `ui/components/ScoreBar.tscn` | 分数对比条 |
| `ui/components/SynergyPanel.tscn` | Synergy面板 |
| `ui/components/JudgePanel.tscn` | 评委面板 |
| `ui/components/ItemTooltip.tscn` | 物品提示 |
| `ui/components/KeywordTooltip.tscn` | 关键词提示 |
| `ui/components/BackpackDrawer.tscn` | 背包抽屉 |
| `ui/components/PhaseBanner.tscn` | 阶段横幅 |
| `ui/components/Playmat.tscn` | 游戏垫 |
| `ui/effects/DishProjectile.tscn` | 菜品投射物 |
| `ui/effects/JudgeAvatar.tscn` | 评委头像 |
| `ui/views/CardInspector.tscn` | 卡牌检视 |
| `tools/AssetGen.tscn` | 资源生成器 |

---

## 10. 开发工具

| 工具 | 说明 |
|------|------|
| `HeadlessSimulator.gd` | 无UI自动对局,验证核心逻辑 |
| `CuisineBalanceTest.gd` | 各菜系胜率/强度分析 |
| `CardPowerRanker.gd` | 卡牌DPS/综合评分排名 |
| `EconomyAnalyzer.gd` | 经济曲线分析 |
| `EncounterCalibrator.gd` | PvE难度曲线校准 |
| `BalanceRunner.gd` | 批量平衡测试 |
| `AssetGenerator.gd` | 批量生成占位资源 |
| `trim_assets.ps1` | ImageMagick裁剪脚本 |
| `process_assets_magick.ps1` | 资源后处理 |

---

## 11. 项目规模统计

| 分类 | 数量 |
|------|------|
| GDScript文件 | ~70+ |
| 场景文件(.tscn) | ~22 |
| 着色器(.gdshader) | 13 |
| 菜品美术 | 159张 |
| 厨师立绘 | 9/10 (90%) |
| 评委立绘 | 3/12 (25%) |
| Autoload单例 | 27个 |
| 设计文档 | 6份 (~200KB) |
| 菜品数据(6池) | ~120+道菜 |
| 食材数据 | ~30种 |
| 厨具数据 | ~20种 |
| 手法数据 | ~15种 |

---

## 12. Legacy代码

以下文件属于旧版战斗系统，可考虑清理:

- `systems/CombatManager.gd` — 旧战斗管理
- `systems/CombatResolver.gd` — 旧战斗解算
- `ui/CombatView.gd` / `.tscn` — 旧战斗视图
- `GameConfig.gd` 中的 legacy constants (MAX_COMBAT_TICKS等)

---

## 13. 待办事项

### 资源缺失
- [ ] 厨师立绘: seija (鬼人正邪)
- [ ] 评委立绘: yuuma, eiki, aya, yukari, tenshi, kokoro, iku, miko, raiko (9个)
- [ ] 评委立绘: 将 `kazami.png` 复制/重命名为 `yuuka.png`

### 功能完善
- [ ] 清理legacy战斗代码
- [ ] 补全教程引导内容
- [ ] 音效/BGM系统 (AudioBridge目前为空壳)
- [ ] ResultScreen升级为逐乘区日志重建

### 平衡调优
- [ ] 运行HeadlessSimulator进行大规模平衡测试
- [ ] PvE难度曲线校准
- [ ] 各菜系胜率均衡化
