# 战斗清晰度优化 + 代码注解 + 美术资源清单

## 一、美术资源清单

### 必做（Tier 1）
| 资源 | 尺寸 | 数量 | 格式 | 说明 |
|------|------|------|------|------|
| 菜品/食材卡面插画 | 150×120px | 40+ | PNG透明底 | 替换 ItemCard 的 ArtFill ColorRect |
| 厨师立绘 | 260×180px | 9张 | PNG透明底 | meiling/kasen/sakuya/reimu/youmu/marisa/patchouli/mokou/seija |
| 四属性图标 | 16×16px | 4个 | PNG透明底 | 味道/卖相/技法/香气 |
| 金币图标 | 16×16px | 1个 | PNG透明底 | 替换价格标签的文字 |

### 重要（Tier 2）
| 资源 | 尺寸 | 数量 | 格式 | 说明 |
|------|------|------|------|------|
| 评委头像 | 48×48px | 9张 | PNG透明底 | yuyuko/yuuma/eiki/aya/yukari等 |
| 关键词图标 | 16×16px | 12个 | PNG透明底 | 每个关键词一个小图标 |
| 菜系徽章 | 24×24px | 6个 | PNG透明底 | 中/法/日/野/分子/甜点 |

### 锦上添花（Tier 3）
| 资源 | 尺寸 | 数量 | 格式 | 说明 |
|------|------|------|------|------|
| 场景背景图 | 1920×1080px | 6张 | PNG/WebP | 可叠加在现有shader上 |
| 粒子贴图 | 32×32px | 4张 | PNG透明底 | 金币/星光/火焰/分数 |

### 推荐目录结构
```
assets/
├── cards/dishes/       ← 菜品插画 (按id命名如 kung_pao.png)
├── cards/ingredients/  ← 食材插画
├── characters/         ← 厨师立绘 (reimu.png, sakuya.png...)
├── icons/stats/        ← flavor.png, presentation.png, technique.png, aroma.png
├── icons/currency/     ← gold.png
├── icons/keywords/     ← umami.png, greasy.png...
├── icons/cuisines/     ← chinese.png, french.png...
├── judges/             ← 评委头像
└── backgrounds/        ← 场景背景
```

---

## 二、战斗清晰度优化

### 2.1 ShowdownResolver 数据追踪增强
- 新增 `_item_cumulative_scores` 追踪每道菜累计得分
- 新增 `_clash_penalties` 记录撞菜惩罚
- `_activate_item()` 信号携带得分拆解数据
- 新增 `get_analysis_data()` 供战后分析使用

### 2.2 ShowdownView 战斗信息面板
- ScoreBar下方新增 BattleInfoPanel：技法倍率 / 香气加速 / 协同效应
- 事件日志按类型着色（上菜=青、关键词=绿、环境=红、撞菜=黄）
- 上菜日志显示得分拆解：`味道12 +鲜美 ×技法1.24 = +18`
- 战斗开始时显示撞菜警告

### 2.3 ScoreBar 增强
- 新增分差显示：`我方领先 +45` (绿) / `对手领先 +30` (红) / `平分秋色`
- DoT标签优化

### 2.4 ResultScreen 战后分析
- 填充 BreakdownLabel（之前一直为空）
- 显示：技法倍率、香气加速、卖相DoT、菜品贡献排名、撞菜惩罚、协同效应
- 评委点评基于实际数据

---

## 三、代码注解
- 新建 GLOSSARY.md 术语表
- 所有 .gd 文件添加文件头注解
- 关键函数添加管线注释

---

## 四、涉及文件

| 文件 | 改动类型 |
|------|----------|
| `systems/ShowdownResolver.gd` | 新增追踪变量+辅助方法+修改信号数据 |
| `systems/ShowdownManager.gd` | 存储分析数据到 MatchState meta |
| `ui/ShowdownView.tscn` | 新增 BattleInfoPanel 节点 |
| `ui/ShowdownView.gd` | 信息面板+日志增强+撞菜警告 |
| `ui/components/ScoreBar.tscn` | 新增 DetailRow 节点 |
| `ui/components/ScoreBar.gd` | 分差显示+DoT优化 |
| `ui/ResultScreen.tscn` | 调整 BreakdownLabel 布局 |
| `ui/ResultScreen.gd` | 实现战后分析+上下文评委点评 |
| `GLOSSARY.md` | 新建术语表 |
| 34个 .gd 文件 | 文件头注解+关键函数注释 |
