# 东方料理对决 - 全面视觉与UX改进方案

## 一、核心问题

1. **视觉品质低** — 纯文字Label堆砌，无色彩层次、无边框装饰、无动效，和大巴扎/炉石差距巨大
2. **信息黑箱** — 物品效果、关键词、评委偏好、羁绊加成全部隐藏，玩家看不懂
3. **零引导** — 没有教程、没有阶段提示、没有胜负条件说明
4. **流程割裂** — 玩家不知道每个阶段在干什么，结算没有明细

## 二、视觉风格定义

### 参考标准
- **大巴扎(The Bazaar)**: 深色背景 + 鲜艳卡牌 + 金色UI镶边 + 品质发光边框 + 物品激活动效
- **炉石(Hearthstone)**: 温暖质感面板 + 宝石品质指示 + 粗体数字 + 悬停放大 + 关键词粗体高亮+tooltip

### 全局色板

```
# 背景层
主背景          #1A1425  深紫黑（暗色沉浸感）
次背景          #2D2340  稍亮紫（面板底色）
面板底色        #231C35  半透明面板 (alpha 0.92)

# UI 镶边
金色镶边        #C9A44A  所有面板/分隔线/标题装饰
暗金            #8B6914  次要边框

# 文字
主文字          #F0E6D3  温暖米白
次文字          #9E95B0  灰紫（说明文字）
强调文字        #FFD700  金色（重要数值、标题）

# 四维属性专色
味道(Flavor)    #FF6B35  暖橙红  图标「味」
卖相(Present)   #E91E9C  亮品红  图标「相」
技法(Technique) #7C4DFF  浓紫    图标「技」
香气(Aroma)     #00E676  翠绿    图标「香」

# 品质/稀有度边框（外发光）
铜 Bronze       #CD7F32  铜色边框 + 微弱外发光
银 Silver       #C0C0C0  银色边框 + 柔和外发光
金 Gold         #FFD700  金色边框 + 明显外发光
钻 Diamond      #B9F2FF  冰蓝边框 + 强烈外发光

# 功能色
增益/正面       #4CAF50  绿色
减益/负面       #F44336  红色
金币            #FFD700  金黄
声望            #E53935  红色星星
冷却条填充      #7C4DFF → #B388FF  紫色渐变
冷却就绪        #00E676  亮绿闪烁

# 菜系配色
中华            #D32F2F  中国红
法式            #1565C0  皇家蓝
和风            #E91E63  樱粉
野味            #2E7D32  森林绿
分子料理        #7C4DFF  科技紫
甜品            #FF8F00  焦糖橙
```

### 全局StyleBox规范

```
所有面板(PanelContainer):
  - bg_color: #231C35 (alpha 0.92)
  - border: 1px #C9A44A (金色镶边)
  - corner_radius: 6px
  - content_margin: 8px all
  - shadow: 外部阴影 offset(0,2) blur(8) color(#00000060)

卡牌(ItemCard):
  - bg_color: #1E1833 → #2A2245 (上到下微渐变，用两层ColorRect实现)
  - border: 2px 品质色（铜/银/金/钻）
  - corner_radius: 8px
  - hover: border变为3px + 品质色外发光(modulate亮度+20%) + scale(1.05)
  - selected: 脉冲发光动画(modulate在1.0~1.3循环)

按钮(Button):
  - normal: bg #3A2D50, border 1px #C9A44A, corner 6px
  - hover: bg #4A3D60, border 1px #FFD700
  - pressed: bg #2A1D40, border 1px #FFD700
  - disabled: bg #2A2240, border 1px #555, font_color #555

分隔线(HSeparator):
  - 用金色1px线 + 两端渐隐效果
```

### 字号规范 (1080p基准)

```
页面大标题:  36-48px 粗体 金色 #FFD700
区域标题:    20-24px 粗体 米白 #F0E6D3
卡牌名称:    16-18px 粗体 米白
属性数值:    15-16px 粗体 各属性专色
正文说明:    14-15px 常规 灰紫 #9E95B0
小标签:      12-13px 常规 各色
```

---

## 三、模块详细方案

### 模块A: 全局主题 + StyleBox基础设施

**目标**: 建立统一的视觉基础，让所有界面自动继承一致的风格。

**内容**:

1. **重写 `themes/default_theme.tres`**:
   - 定义全部控件的默认StyleBox（Button normal/hover/pressed/disabled, PanelContainer, Label颜色, ProgressBar样式等）
   - 设置全局字号、字色
   - 让所有界面不需要单独写样式就有基础美观度

2. **新建 `ui/UIHelper.gd` 工具脚本**:
   - 提供静态方法：创建品质边框StyleBox、创建属性彩色Label、创建发光动画Tween等
   - 避免每个组件重复写StyleBox代码
   - 提供效果描述翻译函数：将 on_activate/triggers 的字典数据翻译成中文可读文本

**涉及文件**:
- `themes/default_theme.tres` — 重写
- `ui/UIHelper.gd` — 新建

---

### 模块B: ItemCard 视觉重做 + 悬停Tooltip

**当前问题**: 卡牌是纯VBox+Label堆砌，无色彩、无层次、无效果说明。

**卡牌新布局(tscn节点树)**:

```
ItemCard (PanelContainer)  — 品质色边框 + 暗色底
├── Margin (MarginContainer, 6px内边距)
│   └── VBox (VBoxContainer, separation=3)
│       ├── HeaderRow (HBox)
│       │   ├── CuisineTag (Label) — 菜系彩色小标签 如 [中华]
│       │   ├── Spacer (Control, expand)
│       │   └── SizeIcon (Label) — 尺寸图标 ■/■■/■■■
│       ├── NameLabel (Label) — 物品名，16px粗体居中
│       ├── StarRow (HBox, 居中) — ★ 用金色Label
│       ├── Separator (ColorRect, 1px高，金色)
│       ├── StatsGrid (GridContainer, 2列)
│       │   ├── FlavorLabel  "味 22"  橙红色
│       │   ├── PresentLabel "相 24"  品红色
│       │   ├── TechLabel    "技 20"  紫色
│       │   └── AromaLabel   "香 18"  绿色
│       ├── CDRow (HBox)
│       │   ├── CDIcon (Label "⏱")
│       │   └── CDBar (ProgressBar) — 紫色渐变填充
│       ├── EffectHint (Label) — 1行简要效果预览，灰紫小字
│       │   例: "上菜时：消耗炙香→+味道"
│       ├── EnchantLabel (Label) — 技法名称，紫色
│       └── PriceLabel (Label) — "💰 5" 金色
```

**视觉效果**:
- 整张卡牌有品质色2px边框 + 8px圆角
- 菜系标签用菜系专色做背景色小胶囊(StyleBoxFlat圆角12px)
- 四维数值各用专属颜色显示，粗体
- CD进度条用紫色渐变StyleBox
- 价格用金色文字

**悬停效果**:
- 卡牌scale → 1.05 (Tween, 0.1秒)
- 边框亮度提升
- 在卡牌右侧弹出 ItemTooltip 详情面板

**ItemTooltip 详情弹窗**:

```
ItemTooltip (PanelContainer) — 固定宽度320px，金色1px边框
├── VBox
│   ├── TitleLabel — 物品全名 + 品质标识 (金色)
│   ├── TypeLabel — "中华料理 · 大型菜品 · ★★★" (灰紫)
│   ├── Sep1
│   ├── StatsDetail — 四维完整展示(带图标和数字)
│   ├── Sep2
│   ├── DescLabel — "北京烤鸭，外皮酥脆，肉质鲜嫩..." (描述文本)
│   ├── Sep3
│   ├── ActivateSection (如有on_activate)
│   │   ├── SectionTitle "【上菜效果】" (金色小标题)
│   │   └── EffectText "消耗所有「炙香」层数，每层+6味道\n获得1层「摆盘」" (白色)
│   ├── TriggerSection (如有triggers)
│   │   ├── SectionTitle "【触发效果】"
│   │   └── TriggerText "相邻菜品上菜时：若有「葱」标签，味道+5"
│   ├── PairingSection (如有pairings)
│   │   ├── SectionTitle "【推荐搭配】"
│   │   └── PairingText "葱丝、薄饼、甜面酱"
│   └── KeywordSection (如涉及关键词)
│       ├── SectionTitle "【相关关键词】"
│       └── KeywordList — 每个关键词: "[鲜美] 增益 — 每层上菜味道+3"
```

**效果描述翻译**: UIHelper.gd 中实现一个函数，将 on_activate 字典翻译成中文:
- `{"type":"gain_keyword","keyword":"plating","stacks":1}` → "获得1层「摆盘」"
- `{"type":"consume_keyword","keyword":"char_aroma","all_stacks":true,"per_stack_bonus":{"flavor":6}}` → "消耗所有「炙香」，每层+6味道"
- `{"type":"stat_bonus","flavor":5}` → "味道+5"

**涉及文件**:
- `ui/components/ItemCard.gd` — 重写
- `ui/components/ItemCard.tscn` — 重写
- `ui/components/ItemTooltip.gd` — 新建
- `ui/components/ItemTooltip.tscn` — 新建
- `ui/UIHelper.gd` — 新建(效果翻译+样式工具)

---

### 模块C: GameBoard 界面重做

**当前问题**: 布局平淡，信息不全，没有阶段指示，没有胜负条件显示。

**新布局(自上而下)**:

```
GameBoard (Control, 全屏)
├── Background (ColorRect #1A1425)
├── VBox (全屏VBoxContainer)
│   ├── TopBar (HBox, 高48px, 底色#231C35, 金色底边)
│   │   ├── PhaseLabel — "🛒 商店阶段" 或 "🔧 准备阶段" (20px粗体金色)
│   │   ├── DayLabel — "第 3 天" (18px白色)
│   │   ├── Spacer
│   │   ├── WinLabel — "胜场 2/10" (18px绿色)
│   │   ├── PrestigeLabel — "★★★★☆" (18px红色/金色)
│   │   └── GoldLabel — "💰 15" (18px金色)
│   │
│   ├── JudgeBar (HBox, 高40px, 底色#2D2340)
│   │   ├── JudgePanel — 两个评委完整信息(名称+偏好简述)
│   │   └── KeywordBar — 当前关键词彩色标签
│   │
│   ├── ShopArea (VBox, 可见性由阶段控制)
│   │   ├── ShopHeader (HBox)
│   │   │   ├── MerchantTabs — "食材 | 菜品 | 技法 | 厨具" 选项卡样式
│   │   │   ├── Spacer
│   │   │   ├── RefreshButton — "🔄 刷新 (💰2)" 带价格提示
│   │   │   └── FreezeButton — "❄ 锁定" (新功能)
│   │   └── ShopScroll
│   │       └── ShopItems (HBox) — 商品卡牌
│   │
│   ├── HSep (金色分隔线)
│   │
│   ├── BoardArea (VBox, flex expand)
│   │   ├── BoardLabel — "料理台" (16px居中)
│   │   ├── BoardScroll
│   │   │   └── BoardSlots (HBox) — 10个槽位
│   │   ├── ToolLabel — "厨具栏" (14px居中)
│   │   └── ToolSlots (HBox)
│   │
│   ├── SynergyBar (HBox, 底色#2D2340) — 当前羁绊列表(详细版)
│   │
│   ├── BackpackArea (VBox, 默认隐藏, 可展开)
│   │   ├── BackpackHeader "背包 (B)"
│   │   └── BackpackItems
│   │
│   └── BottomBar (HBox, 高48px)
│       ├── BackpackToggle — "📦 背包 (3/10)" 显示当前/最大
│       ├── HintLabel — 上下文提示文字(灰紫14px)
│       │   商店阶段: "点击商品购买，拖拽到料理台排列"
│       │   准备阶段: "调整料理台布局，点击准备就绪开始对决"
│       ├── Spacer
│       └── ReadyButton — 大号金色边框按钮 "准备就绪 ▶"

# 悬停Tooltip层(位于最顶层CanvasLayer)
├── TooltipLayer (CanvasLayer)
│   └── ItemTooltip (隐藏，悬停时显示)
```

**阶段切换横幅(PhaseBanner)**:
- 切换阶段时，屏幕中央弹出半透明黑色遮罩上的大字标题
- 用Tween: alpha 0→1→保持1秒→0, 同时scale 1.2→1.0
- 例: 「🛒 商店阶段」下方小字「购买食材和菜品，布置料理台」

**涉及文件**:
- `ui/GameBoard.gd` — 重写
- `ui/GameBoard.tscn` — 重写
- `ui/components/PhaseBanner.gd` — 新建
- `ui/components/PhaseBanner.tscn` — 新建

---

### 模块D: 关键词 / 羁绊 / 评委信息面板

**关键词条(KeywordBar)**:
- 在GameBoard的JudgeBar区域内显示
- 每个关键词用带颜色背景的小胶囊标签:
  - 增益(buff): 绿底白字 `[鲜美 ×2]`
  - 环境(env): 红底白字 `[油腻 ×1]`
  - 印记(mark): 紫底白字 `[标记 ×3]`
- 悬停单个关键词时弹出 KeywordTooltip

**SynergyPanel 重做**:
```
SynergyPanel (PanelContainer, 金色边框)
├── VBox
│   ├── Title "羁绊" (金色16px)
│   ├── ActiveSynergy1 (HBox)
│   │   ├── StatusIcon "✦" (金色=已激活)
│   │   ├── Name "中华料理 (3/3)"
│   │   └── Effect "味道+15%"  (绿色)
│   ├── InactiveSynergy1 (HBox)
│   │   ├── StatusIcon "○" (灰色=未达成)
│   │   ├── Name "融合艺术家 (1/3)" (灰色)
│   │   └── Effect "需3个融合标签" (灰色)
```
- 已激活羁绊: 金色图标 + 白色名称 + 绿色效果
- 未激活: 灰色全部
- 悬停羁绊行时显示完整效果说明

**JudgePanel 重做**:
```
JudgePanel (HBox)
├── Judge1Box (PanelContainer, 小面板)
│   ├── HBox
│   │   ├── Avatar (ColorRect 32x32, 角色代表色)
│   │   └── VBox
│   │       ├── NameLabel "永琳" (白色粗体)
│   │       └── EffectLabel "味道×1.3 | 配方鉴赏" (灰紫小字)
├── Judge2Box (同上)
```
- 悬停评委时弹出完整评委说明tooltip:
  ```
  ══ 八意永琳 ══
  计分偏好: 味道×1.3, 卖相DoT×0.8
  特殊能力: 配方鉴赏
  效果: 拥有「秘方」关键词时效果+50%
  ```

**涉及文件**:
- `ui/components/SynergyPanel.gd + .tscn` — 重写
- `ui/components/JudgePanel.gd + .tscn` — 重写
- `ui/components/KeywordTooltip.gd` — 修改，连接到悬停事件

---

### 模块E: 角色选择界面重做

**新布局**: 左右分栏

```
CharacterSelect (Control)
├── Background (#1A1425)
├── HBox (全屏, 左右分栏)
│   ├── LeftPanel (PanelContainer, 宽360px, 金色边框)
│   │   ├── VBox
│   │   │   ├── Title "选择厨师" (24px金色居中)
│   │   │   ├── Sep
│   │   │   └── ChefGrid (GridContainer 3列)
│   │   │       └── ChefButton × 9 — 每个按钮:
│   │   │           正方形100×100, 中央显示角色名
│   │   │           底色=角色代表菜系色, 选中时金色边框脉冲
│   │   │           悬停时亮度+15%
│   │
│   ├── RightPanel (PanelContainer, flex expand, 金色边框)
│   │   ├── VBox (内边距20px)
│   │   │   ├── ChefName "魂魄妖梦" (36px粗体金色)
│   │   │   ├── CuisineLabel "擅长菜系: 和风 / 野味" (16px白色)
│   │   │   ├── ToolLabel "厨具栏位: 3" (16px白色)
│   │   │   ├── Sep (金色线)
│   │   │   ├── SkillTitle "【固有技能】影分身烹饪" (18px金色)
│   │   │   ├── SkillTrigger "触发: 小型菜品上菜时" (15px灰紫)
│   │   │   ├── SkillEffect "效果: 30%概率双倍得分" (15px白色)
│   │   │   ├── Sep
│   │   │   ├── BaseStats (GridContainer 2列)
│   │   │   │   "味道+2" (橙) "卖相+0" (粉)
│   │   │   │   "技法+3" (紫) "香气+1" (绿)
│   │   │   ├── Sep
│   │   │   ├── StrategyTitle "推荐玩法" (16px金色)
│   │   │   ├── StrategyDesc "多带小型菜品..." (14px灰紫)
│   │   │   ├── Spacer
│   │   │   └── ConfirmButton "确认选择 ▶" (大号金色边框)
│   │
│   └── BackButton "◀ 返回" (左下角)
```

**交互**: 左侧点击角色 → 右侧更新详情 → 点确认才开始

**涉及文件**:
- `ui/CharacterSelect.gd` — 重写
- `ui/CharacterSelect.tscn` — 重写

---

### 模块F: 对决界面 + 结算界面重做

**ShowdownView 改进**:

1. **物品激活视觉反馈**:
   - 物品CD满 → 卡牌边框闪烁亮色(Tween pulse 0.3秒)
   - 飘字效果: 在卡牌上方生成Label "+150味" 金色，Tween上飘60px + alpha渐隐 1秒

2. **事件日志增强**:
   - 用RichTextLabel替代Label，支持BBCode颜色
   - 格式: `[color=#4FC3F7][12.5s][/color] [color=#42A5F5]我方[/color] 北京烤鸭 上菜 → [color=#FF6B35]味道+180[/color]`
   - 对手用红色，我方用蓝色
   - DoT信息用专色

3. **ScoreBar 增强**:
   - 双方分数用大号粗体(24px)
   - 进度条用双色(蓝=我方, 红=对手)
   - 下方增加: "技法倍率: ×1.3 | CD加速: -15%" 等实时倍率显示

4. **倒计时**: 大号显示，最后5秒变红+脉冲

**ResultScreen 重做**:

```
ResultScreen (Control)
├── Background (#1A1425)
├── CenterBox (PanelContainer, 640×520, 金色边框居中)
│   ├── VBox
│   │   ├── ResultTitle "胜利!" (36px, 胜=金色/败=红色/平=白色)
│   │   ├── ScoreLine "285 vs 152" (28px)
│   │   ├── Sep
│   │   ├── BreakdownTitle "得分明细" (18px金色)
│   │   ├── BreakdownGrid (GridContainer 3列: 项目/我方/对手)
│   │   │   "味道直接得分"  "180"  "120"
│   │   │   "卖相持续得分"  "+45"  "+20"
│   │   │   "技法倍率"      "×1.3" "×1.1"
│   │   │   "评委加成"      "+15%" "+0%"
│   │   ├── Sep
│   │   ├── IncomeLabel "收入: 基础8 + 胜利3 = 💰11" (金色)
│   │   ├── PrestigeLabel "声望: ★★★★★ (不变)" 或 "声望: ★★★★★ → ★★★★☆ (-1)"
│   │   ├── WinLabel "胜场: 2/10" (绿色)
│   │   ├── Sep
│   │   ├── JudgeComments
│   │   │   "永琳: 「味道层次丰富，令人回味。」"
│   │   │   "映姬: 「双方实力接近，值得尊敬。」"
│   │   ├── Spacer
│   │   └── ContinueButton "继续 ▶" (金色边框大按钮)
```

**评委评语**: 根据实际分数差异和评委偏好生成，不再随机。

**涉及文件**:
- `ui/ShowdownView.gd + .tscn` — 重写
- `ui/ResultScreen.gd + .tscn` — 重写
- `ui/components/ScoreBar.gd + .tscn` — 重写
- `ui/components/ItemCard.gd` — 添加 flash_activate() 和 float_score() 动画方法

---

### 模块G: 主菜单 + 遭遇界面 + 教程系统

**MainMenu 改进**:
```
MainMenu
├── Background (#1A1425)
├── DecoFrame (PanelContainer, 居中480×400, 金色边框)
│   ├── VBox
│   │   ├── GameTitle "东方料理对决" (48px金色)
│   │   ├── Subtitle "Touhou Culinary Showdown" (16px灰紫)
│   │   ├── Spacer
│   │   ├── Desc "料理台上的弹幕对决\n购买食材，搭配菜品，击败对手" (14px灰紫居中)
│   │   ├── Spacer
│   │   ├── StartButton "开始游戏 ▶" (金色边框大按钮)
│   │   ├── TutorialButton "教程" (普通按钮)
│   │   └── QuitButton "退出" (普通按钮)
```

**EncounterView 改进**:
- 事件标题区域增加事件类型图标和风险等级
- 接受按钮旁显示奖励预览文字
- 事件结果用动画淡入

**TutorialOverlay (首次引导)**:
- 半透明黑色遮罩(alpha 0.7)
- 中央白色文字面板
- 分5步引导，每步高亮一个区域(其余压暗)
- 底部: "下一步" 按钮 + "跳过教程" 按钮
- 步骤:
  1. "欢迎！这是一款料理自走棋。你需要购买食材和菜品排列在料理台上，与对手比拼得分。"
  2. "这是商店。点击物品购买，或拖拽到料理台上。不同商人卖不同类型的商品。" → 高亮商店区
  3. "这是你的料理台。每个菜品在对决时会按冷却时间自动激活，产生得分。" → 高亮料理台
  4. "四种属性: 味道=直接得分, 卖相=持续伤害, 技法=总倍率, 香气=加速冷却" → 高亮属性
  5. "集齐同菜系菜品可触发羁绊加成。准备好后点击准备就绪！" → 高亮就绪按钮

**涉及文件**:
- `ui/MainMenu.gd + .tscn` — 重写
- `ui/EncounterView.gd + .tscn` — 改进
- `ui/TutorialOverlay.gd + .tscn` — 新建

---

### 模块H: BoardSlot 视觉改进

**当前问题**: 槽位只是普通PanelContainer + "空" 文字。

**改进**:
```
BoardSlot (PanelContainer)
├── Background — 空位: 虚线边框#C9A44A(alpha 0.3), 占用: 实色底
├── SlotLabel — 空位显示槽位号"1~10"(小灰字), 引用位显示"◄"
├── CenterContainer — 放置ItemCard的容器
├── HighlightOverlay — 选中时的金色半透明覆盖层
├── DropHint — 拖拽悬停时的虚线框提示
```

- 空槽位: 虚线边框(用多个小ColorRect模拟虚线), 低透明度
- 占用槽位: 无额外边框(卡牌自己有边框)
- 引用槽位(多格物品的延伸): 半透明渐变色, 带"◄"箭头
- 拖拽物品悬停在槽位上时: 槽位边框变亮绿色 #00E676
- 选中槽位: 金色半透明overlay

**涉及文件**:
- `ui/components/BoardSlot.gd` — 改进
- `ui/components/BoardSlot.tscn` — 改进

---

## 四、实施顺序

严格按依赖关系排序:

| 序号 | 模块 | 说明 | 依赖 |
|------|------|------|------|
| 1 | 模块A | 全局主题+UIHelper | 无 |
| 2 | 模块B | ItemCard重做+Tooltip | 模块A |
| 3 | 模块H | BoardSlot视觉改进 | 模块A |
| 4 | 模块C | GameBoard界面重做 | 模块A,B,H |
| 5 | 模块D | 关键词/羁绊/评委面板 | 模块A |
| 6 | 模块E | 角色选择重做 | 模块A |
| 7 | 模块F | 对决+结算重做 | 模块A,B |
| 8 | 模块G | 主菜单+遭遇+教程 | 模块A,C |

## 五、文件变更清单

### 新建文件 (6个)
| 文件 | 说明 |
|------|------|
| `ui/UIHelper.gd` | 样式工具+效果描述翻译 |
| `ui/components/ItemTooltip.gd + .tscn` | 物品悬停详情弹窗 |
| `ui/components/PhaseBanner.gd + .tscn` | 阶段切换横幅 |
| `ui/TutorialOverlay.gd + .tscn` | 首次教程引导 |

### 重写文件 (18个)
| 文件 | 改动 |
|------|------|
| `themes/default_theme.tres` | 全面重写，定义所有控件默认样式 |
| `ui/components/ItemCard.gd + .tscn` | 全面重做布局+视觉+动画 |
| `ui/components/BoardSlot.gd + .tscn` | 视觉增强 |
| `ui/components/SynergyPanel.gd + .tscn` | 重写显示完整羁绊信息 |
| `ui/components/JudgePanel.gd + .tscn` | 重写显示评委详情 |
| `ui/components/ScoreBar.gd + .tscn` | 增强显示倍率/状态 |
| `ui/components/KeywordTooltip.gd + .tscn` | 连接悬停事件 |
| `ui/MainMenu.gd + .tscn` | 增加描述+教程入口 |
| `ui/CharacterSelect.gd + .tscn` | 左右分栏详情 |
| `ui/GameBoard.gd + .tscn` | 全面重做布局+Tooltip系统+阶段提示 |
| `ui/ShowdownView.gd + .tscn` | 激活动画+日志增强 |
| `ui/ResultScreen.gd + .tscn` | 详细结算 |
| `ui/EncounterView.gd + .tscn` | 奖励预览 |

## 六、设计原则

1. **暗色沉浸 + 金色镶边** — 参照大巴扎/炉石的暗底+金装风格
2. **信息三层**: 卡面一眼看懂核心 → 悬停看完整效果 → tooltip看搭配建议
3. **色彩即信息**: 四维各有专色，品质各有发光色，菜系各有底色
4. **动效反馈**: 购买/放置/激活/得分都有视觉反馈(Tween动画)
5. **中文全覆盖**: 所有按钮、标签、提示、效果描述全部中文
6. **不依赖外部美术资源**: 纯StyleBox/ColorRect/Label/ProgressBar实现，不需要任何图片
