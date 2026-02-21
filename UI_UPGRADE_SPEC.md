# 东方料理对决 - UI视觉全面升级实施规格书

> **文档用途**：交付给实施方（AI或开发者），包含完整升级方案 + 当前所有UI源码。实施完成后由项目负责人验收。
>
> **核心要求**：不破坏现有游戏逻辑，仅升级视觉层。所有@onready引用、信号连接、场景路径必须保持兼容。

---

## 一、项目概况

- **引擎**: Godot 4.6, GDScript, Forward Plus渲染
- **分辨率**: 1920x1080, canvas_items stretch
- **项目路径**: `D:\TouhouBazaar`
- **主场景**: `res://ui/MainMenu.tscn`
- **全局主题**: `res://themes/default_theme.tres`
- **现有Autoload**: 18个（详见project.godot节录）

### 项目文件结构（UI相关）

```
D:\TouhouBazaar\
├── project.godot
├── themes/
│   └── default_theme.tres
├── core/
│   └── SignalBus.gd            ← 全局信号总线
├── ui/
│   ├── MainMenu.tscn + .gd
│   ├── CharacterSelect.tscn + .gd
│   ├── GameBoard.tscn + .gd    ← 最复杂的场景
│   ├── ShowdownView.tscn + .gd  ← 战斗场景
│   ├── ResultScreen.tscn + .gd
│   ├── EncounterView.tscn + .gd
│   ├── components/
│   │   ├── ItemCard.tscn + .gd      ← 卡牌组件
│   │   ├── BoardSlot.tscn + .gd     ← 板面格子
│   │   ├── ScoreBar.tscn + .gd      ← 分数条
│   │   ├── JudgePanel.tscn + .gd    ← 评委面板
│   │   ├── SynergyPanel.tscn + .gd  ← 羁绊面板
│   │   └── KeywordTooltip.tscn + .gd ← 关键词提示
│   ├── effects/    ← 新建目录
│   ├── shaders/    ← 新建目录
│   └── fonts/      ← 新建目录
```

---

## 二、升级目标

当前UI完全是文本+色块的原型状态：零图片、零动画、零shader、零自定义字体、零粒子效果。需要全面升级视觉效果，对标 The Bazaar / 炉石酒馆战棋的UI品质。

核心策略：**不依赖外部美术资源**，用Godot 4.6的Shader、Tween动画、GPUParticles2D、StyleBoxFlat实现全部视觉效果。用户会后续用AI生成立绘插画，我们负责所有框架、动画、交互、视觉反馈。

---

## 三、新增文件清单

### 3.1 工具/效果层（注册为Autoload）

| 文件 | 说明 |
|------|------|
| `ui/effects/UIAnimations.gd` | Tween动画工厂：卡牌悬浮、购买闪光、放置弹跳、计分滚动、面板滑入、淡入淡出 |
| `ui/effects/SceneTransition.gd` | 场景切换：CanvasLayer+ColorRect实现黑屏淡入淡出，替换所有`change_scene_to_file` |
| `ui/effects/ParticleFactory.gd` | 粒子工厂：金币飞溅、星光闪烁、烹饪火焰、分数爆发 |
| `ui/effects/UIColors.gd` | 颜色常量：背景色、品阶色(铜银金钻)、菜系色(6系)、关键词类型色、功能色 |
| `ui/effects/FloatingText.gd` | 浮动文字：战斗中的+分数、+关键词弹出 |
| `ui/effects/ScreenFX.gd` | 屏幕特效：震屏、环境滤镜(油腻/疲劳叠层)、压迫感脉冲 |
| `ui/effects/DragManager.gd` | 拖拽管理：拖拽拖影、阴影、有效/无效反馈、吸附过冲动画 |
| `ui/effects/AdjacencyVisualizer.gd` | 相邻关系可视化：选中卡牌时显示触发连线/箭头 |
| `ui/effects/AudioBridge.gd` | 音频桥接：监听SignalBus信号，调用AudioStreamPlayer播放音效（预留接口） |

### 3.2 Shader文件

| 文件 | 效果 |
|------|------|
| `ui/shaders/card_glow.gdshader` | 卡牌边缘发光+脉冲，uniform控制颜色/强度 |
| `ui/shaders/card_holographic.gdshader` | 钻石品阶彩虹全息效果 |
| `ui/shaders/card_frame.gdshader` | 程序化装饰边框：角饰、品阶纹章、铭牌底色渐变 |
| `ui/shaders/card_idle_shimmer.gdshader` | 金/钻品阶卡牌待机微光流动 |
| `ui/shaders/background_gradient.gdshader` | 替代纯色背景，带微动的径向渐变+暗角 |
| `ui/shaders/board_surface.gdshader` | 板面表面材质：木纹/石材质感+微弱法线凹凸+光照响应 |
| `ui/shaders/slot_pulse.gdshader` | 格子拖放高亮脉冲 |
| `ui/shaders/score_bar_fill.gdshader` | 分数条流光填充 |
| `ui/shaders/environment_overlay.gdshader` | 环境debuff全屏滤镜（油腻=黄褐色雾+波纹、味觉疲劳=灰度化） |
| `ui/shaders/dissolve_transition.gdshader` | 场景溶解过渡（备用） |

### 3.3 字体

| 文件 | 说明 |
|------|------|
| `ui/fonts/NotoSansSC-Bold.ttf` | 开源CJK字体（Google Noto Fonts, OFL协议）—— 需下载 |
| `ui/fonts/NotoSansSC-Regular.ttf` | 同上 |

下载地址: `https://github.com/notofonts/noto-cjk/releases` 或 `https://fonts.google.com/noto/specimen/Noto+Sans+SC`

---

## 四、Autoload注册

在`project.godot`的`[autoload]`节最后追加：
```ini
UIAnimations="*res://ui/effects/UIAnimations.gd"
SceneTransition="*res://ui/effects/SceneTransition.gd"
ParticleFactory="*res://ui/effects/ParticleFactory.gd"
UIColors="*res://ui/effects/UIColors.gd"
ScreenFX="*res://ui/effects/ScreenFX.gd"
AudioBridge="*res://ui/effects/AudioBridge.gd"
```

注意：DragManager、AdjacencyVisualizer、FloatingText 不注册为Autoload，由使用方场景实例化。

---

## 五、核心组件升级规格

### 5.1 ItemCard（`ui/components/ItemCard.tscn` + `.gd`）

**升级后节点树**：
```
ItemCard (PanelContainer, ShaderMaterial=card_glow)
  ├─ FrameDecor (Control, ShaderMaterial=card_frame)
  │   ├─ CornerTL / CornerTR / CornerBL / CornerBR (ColorRect, shader画角饰花纹)
  │   └─ TierEmblem (TextureRect/ColorRect, 品阶纹章)
  └─ MarginContainer (6px)
      └─ VBox
          ├─ ArtArea (TextureRect, 预留插画位；默认=菜系色渐变ColorRect)
          │   └─ ShimmerOverlay (ColorRect, ShaderMaterial=card_idle_shimmer, 金/钻阶专用)
          ├─ NamePlate (PanelContainer, 深底+品阶色渐变底纹)
          │   └─ NameLabel (Bold 15px, centered, 描边阴影)
          ├─ StarsRow (HBoxContainer, 品阶星星用Unicode ★)
          ├─ StatsGrid (GridContainer 2列, 属性图标+数值)
          │   ├─ FlavorIcon+Value  PresentationIcon+Value
          │   └─ TechniqueIcon+Value  AromaIcon+Value
          ├─ TagRow (HBoxContainer, 标签胶囊: 圆角色块+白字)
          ├─ CDBar (ProgressBar, 颜色随CD变化绿→黄→红)
          ├─ BottomRow (价格金币图标+数值)
          └─ EnchantBadge (有手法时显示, 青色胶囊)
```

**装饰边框系统** (card_frame shader)：
- shader在边缘区域绘制装饰线条和角饰，用UV坐标+step/smoothstep
- 铜阶(tier 0)：简单单线边框 + 圆角
- 银阶(tier 1)：双线边框 + 四角弧形装饰
- 金阶(tier 2)：三线边框 + 角饰菱形 + 边缘微光流动
- 钻阶(tier 3)：全息彩虹边框 + 角饰旋涡 + card_holographic叠加

**待机动画** (金/钻品阶)：
- card_idle_shimmer shader：一条亮光带以3s周期从左下斜向右上扫过ArtArea
- 钻阶额外：边框颜色缓慢色相旋转(hue shift)

**视觉效果**：
- **card_glow shader**：边缘发光，glow_color=品阶色，hover时intensity从0→1
- **StyleBoxFlat**：圆角8px、品阶色2px边框、6px阴影
- **hover**：scale 1.0→1.08 (0.15s, EASE_OUT+TRANS_BACK)，z_index=10，阴影12px
- **hover out**：scale→1.0 (0.12s, EASE_OUT)，阴影恢复6px
- **拖拽** (DragManager管理)：
  - 原位留30%透明度幽灵
  - 拖拽中：0.9倍 + 8px投影 + ±3°旋转跟随方向
  - 拖影：最近3帧位置淡化
  - 有效目标格：绿色脉冲 + scale 1.05
  - 无效目标：红色闪烁 + 卡牌抖动
  - 放下：吸附过冲TRANS_BACK
- **尺寸**：宽 = 110 + size*40，高 = 200
- **关键词气泡**：右上角显示关键词图标+数字

**必须保留的公开接口**：
- `signal card_clicked(item_data: Dictionary)`
- `signal card_hovered(item_data: Dictionary)`
- `signal card_unhovered()`
- `func setup(data: Dictionary)`
- `func update_cd(current_cd: float)`
- `func _get_drag_data(_at_position: Vector2) -> Variant`

### 5.2 BoardSlot（`ui/components/BoardSlot.tscn` + `.gd`）

- **slot_pulse shader**：拖放到上方时绿色脉冲高亮
- **空状态**：暗色背景 + "+" + 虚线边框(2px, 40%透明)
- **占据状态**：中灰背景 + 微弱边框 + 卡牌投影(4px模糊)
- **放入动画**：缩放0.5→1.1→1.0 + 落地微粒
- **选中高亮**：金色边框2px + 外发光

**必须保留的公开接口**：
- `signal slot_clicked(slot_idx: int)`
- `signal item_dropped(slot_idx: int, drag_data: Dictionary)`
- `func setup(idx: int)`
- `func set_occupied(occupied: bool, is_ref: bool = false)`
- `func set_item_card(card: Control)`
- `func highlight(color: Color)`
- `func clear_highlight()`

### 5.2.1 板面区域（BoardArea背景）

- **board_surface shader**：程序化木纹/石板材质
  - simplex noise + 方向拉伸
  - 暗色调(0.08,0.06,0.04) + 微弱纹理变化
  - 暗角效果
- **卡牌投影**：板上卡牌下方柔和阴影
- **相邻可视化** (AdjacencyVisualizer)：
  - 选中卡牌时显示触发关系连线
  - on_adjacent_activate → 金色弧线(Line2D)
  - pairing关系 → 绿色虚线
  - 箭头标明方向，无关卡牌modulate 70%

### 5.3 ScoreBar

- 分数标签计数滚动动画(0.3s EASE_OUT)
- 进度条Tween平滑过渡
- 领先方分数发光

### 5.4 JudgePanel / SynergyPanel / KeywordTooltip

- JudgePanel：PanelContainer卡片 + 金色边框
- SynergyPanel：胶囊徽章（绿圆角+✓）
- KeywordTooltip：左侧4px彩色竖条(buff绿/环境红/标记紫) + 阴影 + 200ms延迟

---

## 六、场景升级规格

### 6.1 MainMenu.tscn

- 背景：background_gradient.gdshader（深紫径向渐变+微动）
- 标题：透明淡入(0.6s) + 持续微弱脉冲
- 副标题：延迟0.2s淡入
- 按钮：交错从底部滑入
- 场景切换：`SceneTransition.change_scene()`

### 6.2 CharacterSelect.tscn

- 背景：shader渐变
- 厨师卡片：260x180 PanelContainer，含名字/菜系徽章/技能名/描述
- hover：scale 1.08 + 边框金色
- 交错入场：每张间隔80ms，0.8缩放+透明淡入

### 6.3 GameBoard.tscn（最复杂）

- 背景：shader渐变
- 板面区：board_surface shader
- 商人标签着色（食材=土色、菜品=红、技法=青、厨具=银、黑市=紫），底部2px下划线
- **商店仪式**：
  - 刷新：旧卡下滑出(0.15s)，新卡flip_reveal交错入场(60ms间隔)
  - flip_reveal: scale_x 0→1(0.2s)，中间帧背面→正面
  - 已售出：灰度化 + 红色"已售"印章
- **购买成功**：卡牌飞向板面(0.4s贝塞尔) + 金币粒子 + 落地星光
- **购买失败**：左右抖动(3次±8px, 0.3s) + 红闪
- 金币/声望变化：浮动文字
- 背包：滑动动画开关(0.25s)
- 准备按钮：金色边框 + hover加亮 + 就绪时脉冲
- 分隔线：渐变ColorRect替代HSeparator
- 相邻可视化：选中板上卡牌时画触发连线

### 6.4 ShowdownView.tscn（视觉冲击最强）

- 背景：更深渐变，vignette_strength=1.2
- **环境滤镜** (environment_overlay shader)：
  - greasy≥3层：黄褐雾 + 波纹UV偏移
  - taste_fatigue≥2层：灰度化
  - 清除时：滤镜淡出(0.3s) + 清新粒子
- **倒计时**：<10s文字红+脉冲；<5s暗角加重+心跳vignette
- **卡牌激活**：闪白(0.08s) + scale弹(1.08→1.0, 0.2s) + 粒子(8-12个)
  - 高分(flavor>30)：更强闪光 + 更多粒子 + 震屏
- **震屏** (ScreenFX.shake)：轻度±2px/0.1s，中度±5px/0.15s，重度±8px/0.2s+时停
- **连锁弧线**：源卡→目标卡发光弧线(0.3s)，颜色按类型(金/绿/红)
- **CD条**：绿→黄→红，<15%微弱脉冲
- **浮动分数**：向上飘0.8s消失，大分数字号更大+金色
- **关键词弹出**：buff绿/debuff红/标记紫，消耗时红色下沉
- **事件日志**：底部滑入(0.2s)，>8条旧消息淡出(0.15s)
- **对手/我方**：蓝/红区分，领先方发光边框

### 6.5 ResultScreen.tscn

- 标题：0.3倍弹入(TRANS_BACK)，胜利金色/失败红色
- 分数：双方同时从0滚动(1.2s, EASE_OUT)
- 胜利：30粒子两波爆发 + 震屏
- 失败：modulate 0.85 + 红色暗角
- 评委点评：延迟0.5s淡入，间隔0.3s交错
- 继续按钮：底部滑入 + 金色脉冲

### 6.6 EncounterView.tscn

- 面板：圆角12px + 2px边框 + 8px阴影
- 入场：0.9缩放+透明弹入
- 接受按钮绿色系，跳过按钮灰色系
- 结果文字滑入 + 星光粒子

---

## 七、全局主题升级（`themes/default_theme.tres`）

**字体**：
- 默认 → NotoSansSC-Regular 16px
- Button → NotoSansSC-Bold 18px

**Button StyleBoxFlat**：
- Normal: bg(0.14,0.11,0.22) 圆角6 边框1px(0.35,0.30,0.45)
- Hover: bg(0.20,0.16,0.30) 边框(0.6,0.5,0.3)金色调
- Pressed: bg(0.10,0.08,0.16) 边框(1.0,0.85,0.2)亮金

**PanelContainer**: bg(0.10,0.08,0.16,0.9) 圆角8 边框1px(0.25,0.22,0.35)

**ProgressBar**: 背景(0.08,0.06,0.12) 圆角4, 填充(0.30,0.75,0.95) 圆角4

**Separator**: 颜色(0.25,0.20,0.35,0.5) 厚度2px

**ScrollBar**: 宽6px 圆角 半透明

---

## 八、实施顺序

### Phase 1 — 基础设施
1. 下载Noto Sans SC字体到`ui/fonts/`
2. 创建`UIColors.gd`颜色常量
3. 创建10个shader文件
4. 创建`UIAnimations.gd` Tween工厂
5. 创建`SceneTransition.gd`场景过渡
6. 创建`ParticleFactory.gd`粒子工厂
7. 创建`FloatingText.gd`浮动文字
8. 创建`ScreenFX.gd`屏幕特效
9. 创建`DragManager.gd`拖拽管理
10. 创建`AdjacencyVisualizer.gd`相邻关系可视化
11. 创建`AudioBridge.gd`音频桥接
12. 注册新Autoload到`project.godot`
13. 升级`default_theme.tres`

### Phase 2 — 核心组件
14. 重构`ItemCard.tscn` + `.gd`
15. 重构`BoardSlot.tscn` + `.gd`
16. 集成DragManager到拖拽流程

### Phase 3 — 主要场景
17. 升级`MainMenu.tscn` + `.gd`
18. 升级`CharacterSelect.tscn` + `.gd`
19. 升级`GameBoard.tscn` + `.gd`（含商店仪式、购买飞行、相邻可视化）
20. 全局替换`change_scene_to_file`→`SceneTransition.change_scene`

### Phase 4 — 战斗场景
21. 升级`ShowdownView.tscn` + `.gd`
22. 升级`ScoreBar.tscn` + `.gd`
23. 接入浮动分数/关键词弹出
24. 接入粒子到信号
25. 接入ScreenFX震屏
26. 接入environment_overlay
27. 接入连锁弧线

### Phase 5 — 收尾
28. 升级`JudgePanel` / `SynergyPanel` / `KeywordTooltip`
29. 升级`EncounterView.tscn` + `.gd`
30. 升级`ResultScreen.tscn` + `.gd`
31. AudioBridge接入所有信号点
32. 全局测试+性能优化

---

## 九、关键技术决策

1. **Shader代替贴图**：发光、全息、渐变、板面材质全用程序化shader，分辨率无关
2. **TextureRect预留插画位**：ArtArea默认菜系色渐变，后续替换AI生成插画只需设texture
3. **GPUParticles2D**：比CPU粒子性能好，战斗中多系统同时活跃时更稳定
4. **Autoload模式**：与现有18个Autoload架构一致
5. **原地修改**：不新建场景文件，保留路径和信号连接，节点名尽量不变
6. **pivot_offset居中**：Godot 4 Control默认左上角缩放，设置pivot_offset=size/2
7. **Tween自动清理**：node.create_tween()在节点释放时自动清理
8. **DragManager集中管理**：统一处理拖影/投影/反馈
9. **ScreenFX用CanvasLayer(layer=100)**：覆盖所有UI元素
10. **AudioBridge信号驱动**：只监听SignalBus，不改游戏逻辑
11. **AdjacencyVisualizer用Line2D**：独立Control层，不影响卡牌交互
12. **环境滤镜分层**：独立ColorRect(CanvasLayer)，不影响UI交互

---

## 十、验证方案

1. 项目启动无报错，所有Autoload正确加载
2. MainMenu：渐变背景+标题动画+按钮滑入
3. CharacterSelect：厨师卡片hover+边框变金+交错入场
4. GameBoard：商店翻牌、购买飞行+金币粒子、拖放反馈、相邻连线、背包滑动
5. ShowdownView：激活闪白+震屏+浮动分数+连锁弧线+环境滤镜+倒计时压迫
6. ResultScreen：标题弹入+分数滚动+胜利粒子+失败暗化
7. ItemCard：4品阶装饰边框+待机微光+hover+关键词气泡
8. 全场景淡入淡出过渡
9. 中文字体渲染正确
10. 战斗中多粒子+震屏+滤镜不卡顿
11. AudioBridge无音频文件不崩溃
12. 板面材质shader正确

---

## 附录A：当前project.godot

```ini
; Engine configuration file.
config_version=5

[application]
config/name="东方料理对决"
config/description="东方料理对决 - Touhou Cooking Showdown"
run/main_scene="res://ui/MainMenu.tscn"
config/features=PackedStringArray("4.6", "Forward Plus")

[autoload]
SignalBus="*res://core/SignalBus.gd"
GameConfig="*res://data/GameConfig.gd"
DishDatabase="*res://data/DishDatabase.gd"
KeywordDatabase="*res://data/KeywordDatabase.gd"
TechniqueDatabase="*res://data/TechniqueDatabase.gd"
ToolDatabase="*res://data/ToolDatabase.gd"
ChefDatabase="*res://data/ChefDatabase.gd"
JudgeDatabase="*res://data/JudgeDatabase.gd"
CuisineDatabase="*res://data/CuisineDatabase.gd"
CraftingDatabase="*res://data/CraftingDatabase.gd"
GameManager="*res://core/GameManager.gd"
BoardManager="*res://systems/BoardManager.gd"
ShopManager="*res://systems/ShopManager.gd"
ShowdownManager="*res://systems/ShowdownManager.gd"
SynergyManager="*res://systems/SynergyManager.gd"
TechniqueManager="*res://systems/TechniqueManager.gd"
CraftingManager="*res://systems/CraftingManager.gd"
EncounterManager="*res://systems/EncounterManager.gd"

[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"

[gui]
theme/custom="res://themes/default_theme.tres"
```

---

## 附录B：SignalBus.gd（全局信号总线）

```gdscript
extends Node

# === Item Events ===
signal item_activated(player_idx: int, item_idx: int, item_data: Dictionary)
signal item_placed(player_idx: int, item_idx: int, item_data: Dictionary)
signal item_removed(player_idx: int, item_idx: int, item_data: Dictionary)
signal item_sold(player_idx: int, item_data: Dictionary)

# === Keyword Events ===
signal keyword_gained(player_idx: int, item_idx: int, keyword_id: String, stacks: int)
signal keyword_consumed(player_idx: int, keyword_id: String, amount: int)
signal keyword_environment_applied(keyword_id: String, stacks: int, source_player: int)
signal keyword_environment_cleared(keyword_id: String, amount: int)

# === Score Events ===
signal score_produced(player_idx: int, item_idx: int, scores: Dictionary)
signal dot_tick(player_idx: int, dot_amount: float)

# === Trigger Events ===
signal trigger_fired(player_idx: int, item_idx: int, trigger_type: String)

# === Technique Events ===
signal technique_applied(player_idx: int, item_idx: int, technique_id: String)
signal technique_removed(player_idx: int, item_idx: int, old_technique_id: String)

# === Showdown Events ===
signal showdown_started()
signal showdown_tick(elapsed: float)
signal showdown_ended()
signal showdown_item_served(player_idx: int, item_idx: int, score_result: Dictionary)

# === Game Flow Events ===
signal phase_changed(new_phase: int)
signal day_started(day_number: int)
signal day_ended(day_number: int)

# === Shop Events ===
signal shop_refreshed(player_idx: int)
signal item_purchased(player_idx: int, item_data: Dictionary)

# === UI Events ===
signal item_hovered(item_data: Dictionary)
signal item_unhovered()
signal item_clicked(item_data: Dictionary)
signal board_slot_clicked(slot_idx: int)

# === Crafting Events ===
signal craft_completed(player_idx: int, result_item: Dictionary)
signal star_upgraded(player_idx: int, item_data: Dictionary, new_star: int)

# === Synergy Events ===
signal synergy_activated(player_idx: int, synergy_id: String)
signal synergy_deactivated(player_idx: int, synergy_id: String)

# === Encounter Events ===
signal encounter_started(encounter_data: Dictionary)
signal encounter_completed(result: Dictionary)

# === Match Events ===
signal prestige_changed(player_idx: int, old_val: int, new_val: int)
signal player_eliminated(player_idx: int)
signal match_ended(winner_idx: int)
```

---

## 附录C：当前default_theme.tres

```tres
[gd_resource type="Theme" format=3]

[resource]
default_font_size = 16

Button/colors/font_color = Color(0.9, 0.85, 0.75, 1)
Button/colors/font_hover_color = Color(1, 0.9, 0.6, 1)
Button/colors/font_pressed_color = Color(1, 0.85, 0.2, 1)
Button/colors/font_disabled_color = Color(0.4, 0.4, 0.4, 1)
Button/font_sizes/font_size = 16

Label/colors/font_color = Color(0.85, 0.82, 0.75, 1)
Label/font_sizes/font_size = 16

RichTextLabel/colors/default_color = Color(0.85, 0.82, 0.75, 1)
RichTextLabel/font_sizes/normal_font_size = 16

ProgressBar/font_sizes/font_size = 12

BoxContainer/constants/separation = 6
```

---

## 附录D：当前UI源码（完整）

### D.1 MainMenu.gd
```gdscript
extends Control

func _ready():
	$VBox/StartButton.pressed.connect(_on_start)

func _on_start():
	get_tree().change_scene_to_file("res://ui/CharacterSelect.tscn")
```

### D.2 MainMenu.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/MainMenu.gd" id="1"]

[node name="MainMenu" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.08, 0.06, 0.12, 1)

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -200.0
offset_top = -150.0
offset_right = 200.0
offset_bottom = 150.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 30
alignment = 1

[node name="TitleLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 48
text = "东方料理对决"
horizontal_alignment = 1

[node name="SubtitleLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 18
theme_override_colors/font_color = Color(0.7, 0.7, 0.7, 1)
text = "Touhou Culinary Showdown"
horizontal_alignment = 1

[node name="StartButton" type="Button" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(200, 50)
text = "开始游戏"

[node name="SettingsButton" type="Button" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(200, 50)
text = "设置"
disabled = true
```

### D.3 CharacterSelect.gd
```gdscript
extends Control

var _selected_chef: String = ""

func _ready():
	_build_chef_grid()

func _build_chef_grid():
	var grid = $VBox/Grid
	var chefs = ChefDatabase.get_all()
	for chef in chefs:
		var cuisines_text = ", ".join(chef.get("cuisines", []))
		var skill = chef.get("skill", {})
		var btn = Button.new()
		btn.text = "%s\n%s\n%s" % [chef.get("name", ""), cuisines_text, skill.get("name", "")]
		btn.custom_minimum_size = Vector2(180, 120)
		btn.pressed.connect(_on_chef_selected.bind(chef.get("id", "")))
		grid.add_child(btn)

func _on_chef_selected(chef_id: String):
	_selected_chef = chef_id
	GameManager.start_new_game(chef_id)
	get_tree().change_scene_to_file("res://ui/GameBoard.tscn")
```

### D.4 CharacterSelect.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/CharacterSelect.gd" id="1"]

[node name="CharacterSelect" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.08, 0.06, 0.12, 1)

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 20

[node name="TitleLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 36
text = "选择厨师"
horizontal_alignment = 1

[node name="Grid" type="GridContainer" parent="VBox"]
layout_mode = 2
size_flags_horizontal = 4
size_flags_vertical = 6
columns = 3
theme_override_constants/h_separation = 16
theme_override_constants/v_separation = 16

[node name="BackButton" type="Button" parent="VBox"]
layout_mode = 2
size_flags_horizontal = 4
custom_minimum_size = Vector2(160, 40)
text = "返回"
```

### D.5 GameBoard.gd
```gdscript
extends Control

const ItemCardScene = preload("res://ui/components/ItemCard.tscn")
const BoardSlotScene = preload("res://ui/components/BoardSlot.tscn")

var _current_merchant: String = "dish"
var _board_slots: Array = []
var _selected_board_slot: int = -1

@onready var shop_container: HBoxContainer = $VBox/ShopArea/ShopScroll/ShopItems
@onready var merchant_tabs: HBoxContainer = $VBox/ShopArea/MerchantTabs
@onready var board_container: HBoxContainer = $VBox/BoardArea/BoardScroll/BoardSlots
@onready var prestige_label: Label = $VBox/StatusBar/PrestigeLabel
@onready var gold_label: Label = $VBox/StatusBar/GoldLabel
@onready var chef_label: Label = $VBox/StatusBar/ChefLabel
@onready var keyword_label: Label = $VBox/StatusBar/KeywordLabel
@onready var tool_container: HBoxContainer = $VBox/BoardArea/ToolSlots
@onready var backpack_container: HBoxContainer = $VBox/BackpackArea/BackpackScroll/BackpackItems
@onready var backpack_area: Control = $VBox/BackpackArea
@onready var ready_button: Button = $VBox/BottomBar/ReadyButton
@onready var refresh_button: Button = $VBox/ShopArea/RefreshButton
@onready var backpack_toggle: Button = $VBox/BottomBar/BackpackToggle
@onready var synergy_panel = $VBox/StatusBar/SynergyPanel
@onready var judge_panel = $VBox/TopBar/JudgePanel

func _ready():
	_setup_board()
	_setup_signals()
	var match_state = GameManager.get_match_state()
	var player = GameManager.get_player(0)
	if match_state and player and match_state.current_phase == GameConfig.Phase.SHOP:
		if ShopManager.get_shop("dish").is_empty():
			ShopManager.generate_shop(player, match_state.current_day)
	_refresh_all()
	backpack_area.visible = false

func _setup_board():
	for i in range(GameConfig.BOARD_SLOTS):
		var slot = BoardSlotScene.instantiate()
		board_container.add_child(slot)
		slot.setup(i)
		slot.item_dropped.connect(_on_item_dropped_on_slot)
		slot.slot_clicked.connect(_on_slot_clicked)
		_board_slots.append(slot)

func _setup_signals():
	ready_button.pressed.connect(_on_ready)
	refresh_button.pressed.connect(_on_refresh)
	backpack_toggle.pressed.connect(func(): backpack_area.visible = not backpack_area.visible)
	SignalBus.phase_changed.connect(_on_phase_changed)
	SignalBus.item_purchased.connect(func(_p, _i): _refresh_all())
	SignalBus.item_placed.connect(func(_p, _s, _i): _refresh_board())
	SignalBus.item_removed.connect(func(_p, _s, _i): _refresh_board())

	for tab_name in ["ingredient", "dish", "technique", "tool", "blackmarket"]:
		var btn = Button.new()
		btn.text = _get_merchant_display_name(tab_name)
		btn.pressed.connect(_on_merchant_tab.bind(tab_name))
		merchant_tabs.add_child(btn)

func _get_merchant_display_name(merchant: String) -> String:
	match merchant:
		"ingredient": return "食材商人"
		"dish": return "菜品商人"
		"technique": return "技法商人"
		"tool": return "厨具商人"
		"blackmarket": return "黑市商人"
	return merchant

func _refresh_all():
	_refresh_shop()
	_refresh_board()
	_refresh_tools()
	_refresh_status()
	_refresh_backpack()

func _refresh_shop():
	for child in shop_container.get_children():
		child.queue_free()
	for child in merchant_tabs.get_children():
		if child is Button and child.text == "黑市商人":
			child.visible = ShopManager.is_blackmarket_available()
	var shop_items = ShopManager.get_shop(_current_merchant)
	for i in range(shop_items.size()):
		var card = ItemCardScene.instantiate()
		shop_container.add_child(card)
		card.setup(shop_items[i])
		card.set_meta("source_type", "shop")
		card.set_meta("source_index", i)
		card.card_clicked.connect(_on_shop_item_clicked.bind(i))

func _refresh_board():
	var player = GameManager.get_player(0)
	if player == null:
		return
	for i in range(GameConfig.BOARD_SLOTS):
		var slot = _board_slots[i]
		var item = player.board[i]
		if item == null:
			slot.set_occupied(false)
			slot.set_item_card(null)
		elif item.has("_ref_to"):
			slot.set_occupied(true, true)
			slot.set_item_card(null)
		else:
			slot.set_occupied(true)
			var card = ItemCardScene.instantiate()
			slot.set_item_card(card)
			card.setup(item)
			card.set_meta("source_type", "board")
			card.set_meta("source_index", i)
			card.card_clicked.connect(_on_board_item_clicked.bind(i))
	if _selected_board_slot >= 0 and _selected_board_slot < _board_slots.size():
		_board_slots[_selected_board_slot].highlight(Color(0.8, 0.8, 0.2, 0.3))
	var synergies = SynergyManager.check_synergies(player)
	if synergy_panel:
		synergy_panel.update_synergies(synergies)

func _refresh_tools():
	for child in tool_container.get_children():
		child.queue_free()
	var player = GameManager.get_player(0)
	if player == null:
		return
	for i in range(player.tools.size()):
		var card = ItemCardScene.instantiate()
		tool_container.add_child(card)
		card.setup(player.tools[i])
		card.set_meta("draggable", false)

func _refresh_status():
	var player = GameManager.get_player(0)
	if player == null:
		return
	prestige_label.text = "Prestige: %d" % player.prestige
	gold_label.text = "Gold: %d" % player.gold
	var chef = ChefDatabase.get_chef(player.chef_id)
	chef_label.text = chef.get("name", "") if not chef.is_empty() else ""
	var kw_parts: Array[String] = []
	for kw_id in player.keyword_stacks:
		var stacks = player.keyword_stacks[kw_id]
		if stacks > 0:
			var kw = KeywordDatabase.get_keyword(kw_id)
			var name = kw.get("name", kw_id) if not kw.is_empty() else kw_id
			kw_parts.append("%s x%d" % [name, stacks])
	keyword_label.text = " ".join(kw_parts) if not kw_parts.is_empty() else ""
	var match_state = GameManager.get_match_state()
	if match_state and judge_panel:
		judge_panel.update_judges(match_state.judges)

func _refresh_backpack():
	for child in backpack_container.get_children():
		child.queue_free()
	var player = GameManager.get_player(0)
	if player == null:
		return
	for i in range(player.backpack.size()):
		var card = ItemCardScene.instantiate()
		backpack_container.add_child(card)
		card.setup(player.backpack[i])
		card.set_meta("source_type", "backpack")
		card.set_meta("source_index", i)
		card.card_clicked.connect(_on_backpack_item_clicked.bind(i))

func _on_shop_item_clicked(_item_data: Dictionary, shop_index: int):
	var player = GameManager.get_player(0)
	if player == null:
		return
	var bought = ShopManager.buy_item(player, _current_merchant, shop_index)
	if bought.is_empty():
		return
	_handle_bought_item(player, bought)
	_refresh_all()

func _handle_bought_item(player: PlayerState, bought: Dictionary):
	if bought.get("item_type", "") == "tool":
		if player.tools.size() < player.max_tools:
			player.tools.append(bought)
		else:
			player.add_gold(bought.get("price", 0))
		return
	if bought.get("item_type", "") == "technique":
		if not player.add_to_backpack(bought):
			player.add_gold(bought.get("price", 0))
		return
	var placed = BoardManager.auto_place_item(player, bought)
	if placed < 0 and not player.add_to_backpack(bought):
		player.add_gold(bought.get("price", 0))

func _on_board_item_clicked(_item_data: Dictionary, slot_idx: int):
	_selected_board_slot = slot_idx
	for i in range(_board_slots.size()):
		_board_slots[i].clear_highlight()
	if slot_idx >= 0 and slot_idx < _board_slots.size():
		_board_slots[slot_idx].highlight(Color(0.8, 0.8, 0.2, 0.3))

func _on_backpack_item_clicked(item_data: Dictionary, bp_index: int):
	var player = GameManager.get_player(0)
	if player == null:
		return
	if item_data.get("item_type", "") == "technique":
		if _selected_board_slot >= 0 and TechniqueManager.apply_technique(player, _selected_board_slot, item_data.get("id", "")):
			player.remove_from_backpack(bp_index)
			_refresh_all()
		return
	var item = player.remove_from_backpack(bp_index)
	if item != null:
		var placed = BoardManager.auto_place_item(player, item)
		if placed < 0:
			player.add_to_backpack(item)
		_refresh_all()

func _on_item_dropped_on_slot(slot_idx: int, drag_data: Dictionary):
	var player = GameManager.get_player(0)
	if player == null:
		return
	var source_type = String(drag_data.get("source_type", ""))
	var source_index = int(drag_data.get("source_index", -1))
	var item_data = drag_data.get("item_data", {})
	if source_type == "board":
		BoardManager.move_item(player, source_index, slot_idx)
	elif source_type == "backpack":
		var item = player.remove_from_backpack(source_index)
		if item != null:
			if not BoardManager.place_item_on_board(player, item, slot_idx):
				player.add_to_backpack(item)
	elif source_type == "shop":
		var bought = ShopManager.buy_item(player, _current_merchant, source_index)
		if not bought.is_empty():
			if bought.get("item_type", "") == "tool":
				_handle_bought_item(player, bought)
			elif not BoardManager.place_item_on_board(player, bought, slot_idx):
				if not player.add_to_backpack(bought):
					player.add_gold(bought.get("price", 0))
	else:
		BoardManager.place_item_on_board(player, item_data, slot_idx)
	_refresh_all()

func _on_slot_clicked(slot_idx: int):
	_on_board_item_clicked({}, slot_idx)

func _on_merchant_tab(merchant: String):
	_current_merchant = merchant
	_refresh_shop()

func _on_refresh():
	var player = GameManager.get_player(0)
	var match_state = GameManager.get_match_state()
	if player and match_state:
		ShopManager.refresh_shop(player, match_state.current_day)
		_refresh_shop()

func _on_ready():
	GameManager.advance_phase()

func _on_phase_changed(new_phase: int):
	match new_phase:
		GameConfig.Phase.SHOP:
			visible = true
			var player = GameManager.get_player(0)
			var match_state = GameManager.get_match_state()
			if player and match_state and ShopManager.get_shop("dish").is_empty():
				ShopManager.generate_shop(player, match_state.current_day)
			_refresh_all()
		GameConfig.Phase.ENCOUNTER:
			get_tree().change_scene_to_file("res://ui/EncounterView.tscn")
		GameConfig.Phase.PREP:
			visible = true
			_refresh_all()
		GameConfig.Phase.SHOWDOWN:
			get_tree().change_scene_to_file("res://ui/ShowdownView.tscn")

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		backpack_area.visible = not backpack_area.visible
		_refresh_backpack()
```

### D.6 GameBoard.tscn
```tscn
[gd_scene load_steps=4 format=3]

[ext_resource type="Script" path="res://ui/GameBoard.gd" id="1"]
[ext_resource type="PackedScene" path="res://ui/components/SynergyPanel.tscn" id="2"]
[ext_resource type="PackedScene" path="res://ui/components/JudgePanel.tscn" id="3"]

[node name="GameBoard" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.06, 0.05, 0.1, 1)

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 4

[node name="TopBar" type="HBoxContainer" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 40)
theme_override_constants/separation = 20

[node name="DayLabel" type="Label" parent="VBox/TopBar"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "第 1 天"

[node name="JudgePanel" parent="VBox/TopBar" instance=ExtResource("3")]
layout_mode = 2
size_flags_horizontal = 6

[node name="ShopArea" type="VBoxContainer" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 180)
theme_override_constants/separation = 6

[node name="ShopTitle" type="Label" parent="VBox/ShopArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 16
text = "商店"
horizontal_alignment = 1

[node name="MerchantTabs" type="HBoxContainer" parent="VBox/ShopArea"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_constants/separation = 8

[node name="ShopScroll" type="ScrollContainer" parent="VBox/ShopArea"]
layout_mode = 2
size_flags_vertical = 3
horizontal_scroll_mode = 2
vertical_scroll_mode = 0

[node name="ShopItems" type="HBoxContainer" parent="VBox/ShopArea/ShopScroll"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_constants/separation = 8

[node name="RefreshButton" type="Button" parent="VBox/ShopArea"]
layout_mode = 2
size_flags_horizontal = 4
custom_minimum_size = Vector2(120, 32)
text = "刷新商店"

[node name="HSeparator1" type="HSeparator" parent="VBox"]
layout_mode = 2

[node name="StatusBar" type="HBoxContainer" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 36)
theme_override_constants/separation = 24

[node name="PrestigeLabel" type="Label" parent="VBox/StatusBar"]
layout_mode = 2
theme_override_font_sizes/font_size = 16
text = "声望: ★★★★★"

[node name="GoldLabel" type="Label" parent="VBox/StatusBar"]
layout_mode = 2
theme_override_font_sizes/font_size = 16
text = "金币 10"

[node name="ChefLabel" type="Label" parent="VBox/StatusBar"]
layout_mode = 2
theme_override_font_sizes/font_size = 16
text = ""

[node name="KeywordLabel" type="Label" parent="VBox/StatusBar"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_font_sizes/font_size = 14
text = ""

[node name="SynergyPanel" parent="VBox/StatusBar" instance=ExtResource("2")]
layout_mode = 2

[node name="HSeparator2" type="HSeparator" parent="VBox"]
layout_mode = 2

[node name="BoardArea" type="VBoxContainer" parent="VBox"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/separation = 8

[node name="BoardLabel" type="Label" parent="VBox/BoardArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 14
text = "料理台"
horizontal_alignment = 1

[node name="BoardScroll" type="ScrollContainer" parent="VBox/BoardArea"]
layout_mode = 2
size_flags_vertical = 3
horizontal_scroll_mode = 2
vertical_scroll_mode = 0

[node name="BoardSlots" type="HBoxContainer" parent="VBox/BoardArea/BoardScroll"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_constants/separation = 6

[node name="ToolLabel" type="Label" parent="VBox/BoardArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 14
text = "厨具栏"
horizontal_alignment = 1

[node name="ToolSlots" type="HBoxContainer" parent="VBox/BoardArea"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_constants/separation = 6

[node name="HSeparator3" type="HSeparator" parent="VBox"]
layout_mode = 2

[node name="BackpackArea" type="VBoxContainer" parent="VBox"]
layout_mode = 2
theme_override_constants/separation = 4

[node name="BackpackLabel" type="Label" parent="VBox/BackpackArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 14
text = "背包 (B键切换)"
horizontal_alignment = 1

[node name="BackpackScroll" type="ScrollContainer" parent="VBox/BackpackArea"]
layout_mode = 2
custom_minimum_size = Vector2(0, 100)
horizontal_scroll_mode = 2
vertical_scroll_mode = 0

[node name="BackpackItems" type="HBoxContainer" parent="VBox/BackpackArea/BackpackScroll"]
layout_mode = 2
theme_override_constants/separation = 6

[node name="BottomBar" type="HBoxContainer" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 44)
theme_override_constants/separation = 16

[node name="BackpackToggle" type="Button" parent="VBox/BottomBar"]
layout_mode = 2
custom_minimum_size = Vector2(120, 36)
text = "背包"

[node name="CraftHint" type="Label" parent="VBox/BottomBar"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_font_sizes/font_size = 13
theme_override_colors/font_color = Color(0.6, 0.6, 0.6, 1)
text = "拖拽物品到料理台上排列"
vertical_alignment = 1

[node name="ReadyButton" type="Button" parent="VBox/BottomBar"]
layout_mode = 2
custom_minimum_size = Vector2(140, 36)
text = "准备就绪"
```

### D.7 ShowdownView.gd
```gdscript
extends Control

const ItemCardScene = preload("res://ui/components/ItemCard.tscn")

@onready var timer_label: Label = $VBox/TopBar/TimerLabel
@onready var judge_label: Label = $VBox/TopBar/JudgeLabel
@onready var opponent_board: HBoxContainer = $VBox/OpponentArea/OpponentScroll/OpponentBoard
@onready var opponent_keywords: Label = $VBox/OpponentArea/OpponentKeywords
@onready var score_bar = $VBox/ScoreArea/ScoreBar
@onready var event_log: VBoxContainer = $VBox/EventLog
@onready var player_board: HBoxContainer = $VBox/PlayerArea/PlayerScroll/PlayerBoard
@onready var player_keywords: Label = $VBox/PlayerArea/PlayerKeywords

var _resolver: ShowdownResolver = null

func _ready():
	var match_state = GameManager.get_match_state()
	if match_state == null:
		return
	var judge_names := []
	for j in match_state.judges:
		judge_names.append(j.get("name", "???"))
	judge_label.text = "Judges: " + " + ".join(judge_names)
	_setup_board_display(0, player_board)
	_setup_board_display(1, opponent_board)
	ShowdownManager.start_showdown(match_state)
	_resolver = ShowdownManager.get_resolver()
	SignalBus.showdown_tick.connect(_on_tick)
	SignalBus.showdown_item_served.connect(_on_item_served)
	SignalBus.showdown_ended.connect(_on_showdown_ended)
	SignalBus.dot_tick.connect(_on_dot_tick)

func _setup_board_display(player_idx: int, container: HBoxContainer):
	for child in container.get_children():
		child.queue_free()
	var player = GameManager.get_player(player_idx)
	if player == null:
		return
	for entry in player.get_board_items():
		var card = ItemCardScene.instantiate()
		container.add_child(card)
		card.setup(entry.item)
		card.set_meta("draggable", false)

func _on_tick(elapsed: float):
	var remaining = maxf(0.0, GameConfig.SHOWDOWN_DURATION - elapsed)
	timer_label.text = "%ds" % int(remaining)
	if _resolver:
		var scores = _resolver.get_scores()
		score_bar.update_scores(scores[0], scores[1])
		var match_state = GameManager.get_match_state()
		if match_state:
			score_bar.update_environment(match_state.environment_keywords)
		for p_idx in range(2):
			var container = player_board if p_idx == 0 else opponent_board
			var runtimes = _resolver.get_item_runtimes(p_idx)
			var cards = container.get_children()
			for i in range(mini(cards.size(), runtimes.size())):
				if cards[i].has_method("update_cd"):
					cards[i].update_cd(float(runtimes[i].current_cd))
	var p0 = GameManager.get_player(0)
	var p1 = GameManager.get_player(1)
	if p0:
		player_keywords.text = _format_keywords(p0)
	if p1:
		opponent_keywords.text = _format_keywords(p1)

func _on_dot_tick(player_idx: int, dot: float):
	score_bar.update_dot(dot, player_idx)

func _format_keywords(player) -> String:
	var parts := []
	for kw_id in player.keyword_stacks:
		var stacks = player.keyword_stacks[kw_id]
		if stacks > 0:
			var kw = KeywordDatabase.get_keyword(kw_id)
			var kw_name = kw.get("name", kw_id) if not kw.is_empty() else kw_id
			parts.append("%s x%d" % [kw_name, stacks])
	return " ".join(parts)

func _on_item_served(player_idx: int, _item_idx: int, result: Dictionary):
	var item = result.get("item", {})
	var flavor = result.get("flavor", 0)
	var side = "P1" if player_idx == 0 else "P2"
	var text = "%s served %s (flavor +%d)" % [side, item.get("name", "???"), int(flavor)]
	_add_log(text)

func _add_log(text: String):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 14)
	event_log.add_child(label)
	while event_log.get_child_count() > 8:
		event_log.get_child(0).queue_free()

func _on_showdown_ended():
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://ui/ResultScreen.tscn")
```

### D.8 ShowdownView.tscn
```tscn
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://ui/ShowdownView.gd" id="1"]
[ext_resource type="PackedScene" path="res://ui/components/ScoreBar.tscn" id="2"]

[node name="ShowdownView" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.05, 0.04, 0.08, 1)

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 8

[node name="TopBar" type="HBoxContainer" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 40)
theme_override_constants/separation = 20

[node name="TimerLabel" type="Label" parent="VBox/TopBar"]
layout_mode = 2
theme_override_font_sizes/font_size = 28
text = "30秒"

[node name="JudgeLabel" type="Label" parent="VBox/TopBar"]
layout_mode = 2
size_flags_horizontal = 3
theme_override_font_sizes/font_size = 16
text = "评委: "
vertical_alignment = 1

[node name="OpponentArea" type="VBoxContainer" parent="VBox"]
layout_mode = 2
theme_override_constants/separation = 4

[node name="OpponentLabel" type="Label" parent="VBox/OpponentArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 14
theme_override_colors/font_color = Color(0.9, 0.3, 0.3, 1)
text = "对手料理台"
horizontal_alignment = 1

[node name="OpponentScroll" type="ScrollContainer" parent="VBox/OpponentArea"]
layout_mode = 2
custom_minimum_size = Vector2(0, 100)
horizontal_scroll_mode = 2
vertical_scroll_mode = 0

[node name="OpponentBoard" type="HBoxContainer" parent="VBox/OpponentArea/OpponentScroll"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_constants/separation = 6

[node name="OpponentKeywords" type="Label" parent="VBox/OpponentArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 13
theme_override_colors/font_color = Color(0.7, 0.5, 0.5, 1)
text = ""
horizontal_alignment = 1

[node name="HSeparator1" type="HSeparator" parent="VBox"]
layout_mode = 2

[node name="ScoreArea" type="HBoxContainer" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 50)
size_flags_horizontal = 4

[node name="ScoreBar" parent="VBox/ScoreArea" instance=ExtResource("2")]
layout_mode = 2
size_flags_horizontal = 3

[node name="HSeparator2" type="HSeparator" parent="VBox"]
layout_mode = 2

[node name="EventLog" type="VBoxContainer" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 120)
theme_override_constants/separation = 2

[node name="PlayerArea" type="VBoxContainer" parent="VBox"]
layout_mode = 2
size_flags_vertical = 3
theme_override_constants/separation = 4

[node name="PlayerLabel" type="Label" parent="VBox/PlayerArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 14
theme_override_colors/font_color = Color(0.3, 0.7, 0.9, 1)
text = "我方料理台"
horizontal_alignment = 1

[node name="PlayerScroll" type="ScrollContainer" parent="VBox/PlayerArea"]
layout_mode = 2
size_flags_vertical = 3
horizontal_scroll_mode = 2
vertical_scroll_mode = 0

[node name="PlayerBoard" type="HBoxContainer" parent="VBox/PlayerArea/PlayerScroll"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_constants/separation = 6

[node name="PlayerKeywords" type="Label" parent="VBox/PlayerArea"]
layout_mode = 2
theme_override_font_sizes/font_size = 13
theme_override_colors/font_color = Color(0.5, 0.7, 0.8, 1)
text = ""
horizontal_alignment = 1
```

### D.9 ResultScreen.gd
```gdscript
extends Control

@onready var title_label: Label = $VBox/TitleLabel
@onready var score_label: Label = $VBox/ScoreLabel
@onready var breakdown_label: Label = $VBox/BreakdownLabel
@onready var judge_comment: Label = $VBox/JudgeComment
@onready var prestige_label: Label = $VBox/PrestigeLabel
@onready var continue_button: Button = $VBox/ContinueButton

func _ready():
	var match_state = GameManager.get_match_state()
	if match_state == null:
		return
	var scores = match_state.showdown_scores
	var p0 = match_state.get_player(0)
	var p1 = match_state.get_player(1)
	if scores[0] > scores[1]:
		title_label.text = "=== 胜利! ==="
		title_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	elif scores[1] > scores[0]:
		title_label.text = "=== 惜败 ==="
		title_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
	else:
		title_label.text = "=== 平局 ==="
	score_label.text = "最终得分: %d vs %d" % [int(scores[0]), int(scores[1])]
	var comments := []
	for judge in match_state.judges:
		var jname = judge.get("name", "???")
		var comment = _generate_comment(judge, scores)
		comments.append('%s: "%s"' % [jname, comment])
	judge_comment.text = "\n".join(comments)
	prestige_label.text = "声望: " + "★".repeat(p0.prestige) + "☆".repeat(maxi(0, GameConfig.STARTING_PRESTIGE - p0.prestige))
	continue_button.pressed.connect(_on_continue)

func _generate_comment(judge: Dictionary, scores: Array) -> String:
	var comments_win = ["精彩的料理!", "味道令人沉醉。", "技法出众!", "完美的呈现。"]
	var comments_lose = ["还需要更多练习。", "味道有些欠缺。", "摆盘可以更好。", "期待下次的表现。"]
	if scores[0] > scores[1]:
		return comments_win[randi() % comments_win.size()]
	else:
		return comments_lose[randi() % comments_lose.size()]

func _on_continue():
	var match_state = GameManager.get_match_state()
	if match_state:
		var p0 = match_state.get_player(0)
		if p0.prestige <= 0:
			get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
			return
		if p0.wins >= 10:
			get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
			return
	GameManager.advance_phase()
	get_tree().change_scene_to_file("res://ui/GameBoard.tscn")
```

### D.10 ResultScreen.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/ResultScreen.gd" id="1"]

[node name="ResultScreen" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.06, 0.05, 0.1, 1)

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -300.0
offset_top = -250.0
offset_right = 300.0
offset_bottom = 250.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 24
alignment = 1

[node name="TitleLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 40
text = "=== 结果 ==="
horizontal_alignment = 1

[node name="ScoreLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 24
text = "最终得分: 0 vs 0"
horizontal_alignment = 1

[node name="BreakdownLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 16
text = ""
horizontal_alignment = 1
autowrap_mode = 2

[node name="JudgeComment" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 16
theme_override_colors/font_color = Color(0.8, 0.75, 0.6, 1)
text = ""
horizontal_alignment = 1
autowrap_mode = 2

[node name="PrestigeLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 20
text = "声望: "
horizontal_alignment = 1

[node name="ContinueButton" type="Button" parent="VBox"]
layout_mode = 2
size_flags_horizontal = 4
custom_minimum_size = Vector2(200, 50)
text = "继续"
```

### D.11 EncounterView.gd
```gdscript
extends Control

var _encounter: Dictionary = {}

@onready var title_label: Label = $VBox/TitleLabel
@onready var desc_label: Label = $VBox/DescLabel
@onready var accept_button: Button = $VBox/Buttons/AcceptButton
@onready var skip_button: Button = $VBox/Buttons/SkipButton
@onready var result_label: Label = $VBox/ResultLabel

func _ready():
	var match_state = GameManager.get_match_state()
	if match_state:
		_encounter = EncounterManager.generate_encounter(match_state.current_day)
	title_label.text = _encounter.get("name", "Encounter")
	desc_label.text = _encounter.get("description", "")
	result_label.visible = false
	accept_button.pressed.connect(_on_accept)
	skip_button.pressed.connect(_on_skip)

func _on_accept():
	var player = GameManager.get_player(0)
	if player:
		var result = EncounterManager.resolve_encounter(player, _encounter)
		for reward in result.get("rewards", []):
			var placed = BoardManager.auto_place_item(player, reward)
			if placed < 0:
				player.add_to_backpack(reward)
		var text = "Completed"
		if result.has("gold_gained"):
			text += ", +%d gold" % result.gold_gained
		if not result.get("rewards", []).is_empty():
			text += ", rewards acquired"
		result_label.text = text
		result_label.visible = true
	accept_button.visible = false
	skip_button.text = "Continue"

func _on_skip():
	GameManager.advance_phase()
	get_tree().change_scene_to_file("res://ui/GameBoard.tscn")
```

### D.12 EncounterView.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/EncounterView.gd" id="1"]

[node name="EncounterView" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="Background" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.07, 0.06, 0.11, 1)

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 8
anchor_left = 0.5
anchor_top = 0.5
anchor_right = 0.5
anchor_bottom = 0.5
offset_left = -280.0
offset_top = -200.0
offset_right = 280.0
offset_bottom = 200.0
grow_horizontal = 2
grow_vertical = 2
theme_override_constants/separation = 20
alignment = 1

[node name="TitleLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 32
text = "事件"
horizontal_alignment = 1

[node name="DescLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 18
text = ""
horizontal_alignment = 1
autowrap_mode = 2

[node name="Buttons" type="HBoxContainer" parent="VBox"]
layout_mode = 2
size_flags_horizontal = 4
theme_override_constants/separation = 24

[node name="AcceptButton" type="Button" parent="VBox/Buttons"]
layout_mode = 2
custom_minimum_size = Vector2(160, 44)
text = "接受"

[node name="SkipButton" type="Button" parent="VBox/Buttons"]
layout_mode = 2
custom_minimum_size = Vector2(160, 44)
text = "跳过"

[node name="ResultLabel" type="Label" parent="VBox"]
layout_mode = 2
theme_override_font_sizes/font_size = 18
theme_override_colors/font_color = Color(0.3, 0.8, 0.4, 1)
text = ""
horizontal_alignment = 1
```

### D.13 ItemCard.gd
```gdscript
extends PanelContainer

signal card_clicked(item_data: Dictionary)
signal card_hovered(item_data: Dictionary)
signal card_unhovered()

var item_data: Dictionary = {}

@onready var name_label: Label = $VBox/NameLabel
@onready var stars_label: Label = $VBox/StarsLabel
@onready var stats_label: Label = $VBox/StatsLabel
@onready var cd_bar: ProgressBar = $VBox/CDBar
@onready var tags_label: Label = $VBox/TagsLabel
@onready var price_label: Label = $VBox/PriceLabel
@onready var enchant_label: Label = $VBox/EnchantLabel

func setup(data: Dictionary):
	item_data = data
	if is_inside_tree():
		_update_display()

func _ready():
	_update_display()

func _update_display():
	if name_label == null:
		return
	if item_data.is_empty():
		visible = false
		return
	visible = true
	name_label.text = item_data.get("name", "???")
	var star = int(item_data.get("star_level", 1))
	stars_label.text = "*".repeat(star) if star > 1 else ""
	stars_label.visible = star > 1
	var stats = item_data.get("base_stats", {})
	stats_label.text = "F%d P%d T%d A%d" % [
		int(stats.get("flavor", 0)),
		int(stats.get("presentation", 0)),
		int(stats.get("technique", 0)),
		int(stats.get("aroma", 0)),
	]
	var cd = float(item_data.get("cooldown", 0.0))
	cd_bar.max_value = maxf(0.1, cd)
	cd_bar.value = cd
	cd_bar.visible = cd > 0.0
	var tags = item_data.get("tags", [])
	tags_label.text = " ".join(tags.slice(0, 3)) if not tags.is_empty() else ""
	tags_label.visible = not tags.is_empty()
	var price = int(item_data.get("price", 0))
	price_label.text = "$%d" % price if price > 0 else ""
	price_label.visible = price > 0
	var enchant = item_data.get("enchant", "")
	if enchant != "":
		var tech = TechniqueDatabase.get_technique(enchant)
		enchant_label.text = "[%s]" % tech.get("name", enchant)
	else:
		enchant_label.text = ""
	enchant_label.visible = enchant != ""
	var tier = item_data.get("tier", "bronze")
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	match tier:
		"bronze":
			style.border_color = Color(0.7, 0.5, 0.3)
		"silver":
			style.border_color = Color(0.7, 0.7, 0.8)
		"gold":
			style.border_color = Color(1.0, 0.85, 0.2)
		"diamond":
			style.border_color = Color(0.5, 0.8, 1.0)
	add_theme_stylebox_override("panel", style)
	var size = int(item_data.get("size", 1))
	custom_minimum_size.x = 80 + size * 40

func update_cd(current_cd: float):
	if cd_bar == null:
		return
	cd_bar.value = current_cd

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_clicked.emit(item_data)

func _on_mouse_entered():
	card_hovered.emit(item_data)
	SignalBus.item_hovered.emit(item_data)

func _on_mouse_exited():
	card_unhovered.emit()
	SignalBus.item_unhovered.emit()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_data.is_empty():
		return null
	if not bool(get_meta("draggable", true)):
		return null
	var preview = Label.new()
	preview.text = item_data.get("name", "?")
	set_drag_preview(preview)
	return {
		"type": "item_card",
		"item_data": item_data,
		"source": self,
		"source_type": get_meta("source_type", ""),
		"source_index": int(get_meta("source_index", -1)),
	}
```

### D.14 ItemCard.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/components/ItemCard.gd" id="1"]

[node name="ItemCard" type="PanelContainer"]
custom_minimum_size = Vector2(120, 160)
script = ExtResource("1")

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 2

[node name="NameLabel" type="Label" parent="VBox"]
layout_mode = 2
horizontal_alignment = 1
text = "菜品名"

[node name="StarsLabel" type="Label" parent="VBox"]
layout_mode = 2
horizontal_alignment = 1
text = "★"

[node name="StatsLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "味0 相0 技0 香0"

[node name="CDBar" type="ProgressBar" parent="VBox"]
layout_mode = 2
custom_minimum_size = Vector2(0, 12)
max_value = 10.0
value = 10.0
show_percentage = false

[node name="TagsLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "[标签]"

[node name="PriceLabel" type="Label" parent="VBox"]
layout_mode = 2
horizontal_alignment = 1
text = "💰 0"

[node name="EnchantLabel" type="Label" parent="VBox"]
layout_mode = 2
horizontal_alignment = 1
text = ""
```

### D.15 BoardSlot.gd
```gdscript
extends PanelContainer

signal slot_clicked(slot_idx: int)
signal item_dropped(slot_idx: int, drag_data: Dictionary)

var slot_idx: int = 0
var _occupied: bool = false
var _is_reference: bool = false
var _item_card: Control = null

@onready var slot_label: Label = $CenterContainer/SlotLabel

func setup(idx: int):
	slot_idx = idx
	if is_inside_tree():
		_update_display()

func _ready():
	_update_display()

func set_occupied(occupied: bool, is_ref: bool = false):
	_occupied = occupied
	_is_reference = is_ref
	if is_inside_tree():
		_update_display()

func set_item_card(card: Control):
	if _item_card != null and _item_card.get_parent() == $CenterContainer:
		_item_card.queue_free()
	_item_card = card
	if card != null:
		$CenterContainer.add_child(card)
		slot_label.visible = false
	else:
		slot_label.visible = true
	if is_inside_tree():
		_update_display()

func _update_display():
	if slot_label == null:
		return
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	if _is_reference:
		style.bg_color = Color(0.2, 0.2, 0.25, 0.5)
		style.border_color = Color(0.3, 0.3, 0.35)
		slot_label.text = "..."
	elif _occupied:
		style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
		style.border_color = Color(0.4, 0.4, 0.5)
	else:
		style.bg_color = Color(0.1, 0.1, 0.15, 0.6)
		style.border_color = Color(0.3, 0.3, 0.35)
		slot_label.text = "Empty"
	add_theme_stylebox_override("panel", style)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.get("type") == "item_card":
		return not _occupied
	return false

func _drop_data(_at_position: Vector2, data: Variant):
	if data is Dictionary and data.get("type") == "item_card":
		item_dropped.emit(slot_idx, data)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		slot_clicked.emit(slot_idx)

func highlight(color: Color = Color(0.3, 0.6, 0.3, 0.3)):
	var style = get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style:
		style.bg_color = color
		add_theme_stylebox_override("panel", style)

func clear_highlight():
	_update_display()
```

### D.16 BoardSlot.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/components/BoardSlot.gd" id="1"]

[node name="BoardSlot" type="PanelContainer"]
custom_minimum_size = Vector2(80, 140)
script = ExtResource("1")

[node name="CenterContainer" type="CenterContainer" parent="."]
layout_mode = 2

[node name="SlotLabel" type="Label" parent="CenterContainer"]
layout_mode = 2
text = "空"
horizontal_alignment = 1
vertical_alignment = 1
```

### D.17 ScoreBar.gd
```gdscript
extends VBoxContainer

@onready var p1_score_label: Label = $ScoreRow/P1Score
@onready var p2_score_label: Label = $ScoreRow/P2Score
@onready var p1_bar: ProgressBar = $ScoreRow/BarContainer/P1Bar
@onready var p2_bar: ProgressBar = $ScoreRow/BarContainer/P2Bar
@onready var dot_label: Label = $InfoRow/DotLabel
@onready var env_label: Label = $InfoRow/EnvLabel

func update_scores(p1_score: float, p2_score: float):
	if p1_score_label == null:
		return
	p1_score_label.text = "%d" % int(p1_score)
	p2_score_label.text = "%d" % int(p2_score)
	var total = maxf(1.0, p1_score + p2_score)
	p1_bar.max_value = total
	p1_bar.value = p1_score
	p2_bar.max_value = total
	p2_bar.value = p2_score

func update_dot(dot_per_sec: float, leading_player: int):
	if dot_label == null:
		return
	if absf(dot_per_sec) < 0.01:
		dot_label.text = "Presentation DoT: --"
	else:
		var side = "P1" if leading_player == 0 else "P2"
		dot_label.text = "Presentation DoT: %s +%.1f/s" % [side, dot_per_sec]

func update_environment(env_keywords: Dictionary):
	if env_label == null:
		return
	var parts := []
	for kw_id in env_keywords:
		var stacks = env_keywords[kw_id]
		if stacks > 0:
			var kw = KeywordDatabase.get_keyword(kw_id)
			var name = kw.get("name", kw_id) if not kw.is_empty() else kw_id
			parts.append("%s x%d" % [name, stacks])
	env_label.text = "Environment: " + (" ".join(parts) if not parts.is_empty() else "None")
```

### D.18 ScoreBar.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/components/ScoreBar.gd" id="1"]

[node name="ScoreBar" type="VBoxContainer"]
script = ExtResource("1")

[node name="ScoreRow" type="HBoxContainer" parent="."]
layout_mode = 2

[node name="P2Score" type="Label" parent="ScoreRow"]
layout_mode = 2
size_flags_horizontal = 3
horizontal_alignment = 2
text = "0"

[node name="BarContainer" type="HBoxContainer" parent="ScoreRow"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_stretch_ratio = 4.0

[node name="P2Bar" type="ProgressBar" parent="ScoreRow/BarContainer"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 1
custom_minimum_size = Vector2(0, 20)
max_value = 100.0
value = 50.0
fill_mode = 1
show_percentage = false

[node name="P1Bar" type="ProgressBar" parent="ScoreRow/BarContainer"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 1
custom_minimum_size = Vector2(0, 20)
max_value = 100.0
value = 50.0
show_percentage = false

[node name="P1Score" type="Label" parent="ScoreRow"]
layout_mode = 2
size_flags_horizontal = 3
text = "0"

[node name="InfoRow" type="HBoxContainer" parent="."]
layout_mode = 2

[node name="DotLabel" type="Label" parent="InfoRow"]
layout_mode = 2
size_flags_horizontal = 3
text = "卖相DoT: --"

[node name="EnvLabel" type="Label" parent="InfoRow"]
layout_mode = 2
size_flags_horizontal = 3
horizontal_alignment = 2
text = "环境: --"
```

### D.19 JudgePanel.gd
```gdscript
extends HBoxContainer

func update_judges(judges: Array):
	if not is_inside_tree():
		return
	if judges.size() >= 1:
		var n1 = get_node_or_null("Judge1/Name1")
		var p1 = get_node_or_null("Judge1/Pref1")
		if n1:
			n1.text = judges[0].get("name", "???")
		if p1:
			var special1 = judges[0].get("special", {})
			p1.text = special1.get("name", "")
	if judges.size() >= 2:
		var n2 = get_node_or_null("Judge2/Name2")
		var p2 = get_node_or_null("Judge2/Pref2")
		if n2:
			n2.text = judges[1].get("name", "???")
		if p2:
			var special2 = judges[1].get("special", {})
			p2.text = special2.get("name", "")
```

### D.20 JudgePanel.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/components/JudgePanel.gd" id="1"]

[node name="JudgePanel" type="HBoxContainer"]
script = ExtResource("1")

[node name="Judge1" type="VBoxContainer" parent="."]
layout_mode = 2
size_flags_horizontal = 3

[node name="Name1" type="Label" parent="Judge1"]
layout_mode = 2
horizontal_alignment = 1
text = "评委1"

[node name="Pref1" type="Label" parent="Judge1"]
layout_mode = 2
horizontal_alignment = 1
text = "偏好"

[node name="Judge2" type="VBoxContainer" parent="."]
layout_mode = 2
size_flags_horizontal = 3

[node name="Name2" type="Label" parent="Judge2"]
layout_mode = 2
horizontal_alignment = 1
text = "评委2"

[node name="Pref2" type="Label" parent="Judge2"]
layout_mode = 2
horizontal_alignment = 1
text = "偏好"
```

### D.21 SynergyPanel.gd
```gdscript
extends VBoxContainer

@onready var list_container: VBoxContainer = $List

func update_synergies(active_synergies: Array):
	if list_container == null:
		return
	for child in list_container.get_children():
		child.queue_free()
	for syn in active_synergies:
		var label = Label.new()
		label.text = "✓ %s" % syn.get("name", "???")
		label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
		list_container.add_child(label)
```

### D.22 SynergyPanel.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/components/SynergyPanel.gd" id="1"]

[node name="SynergyPanel" type="VBoxContainer"]
custom_minimum_size = Vector2(300, 0)
script = ExtResource("1")

[node name="Title" type="Label" parent="."]
layout_mode = 2
text = "Synergy"

[node name="List" type="VBoxContainer" parent="."]
layout_mode = 2
```

### D.23 KeywordTooltip.gd
```gdscript
extends PanelContainer

@onready var name_label: Label = $VBox/NameLabel
@onready var type_label: Label = $VBox/TypeLabel
@onready var desc_label: Label = $VBox/DescLabel
@onready var stacks_label: Label = $VBox/StacksLabel

func show_keyword(keyword_id: String, stacks: int = 0):
	var kw = KeywordDatabase.get_keyword(keyword_id)
	if kw.is_empty():
		visible = false
		return
	if name_label == null:
		return
	name_label.text = "[%s]" % kw.get("name", keyword_id)
	var type_text = ""
	match kw.get("type", ""):
		"buff":
			type_text = "Buff"
		"environment":
			type_text = "Environment"
		"mark":
			type_text = "Mark"
	type_label.text = type_text
	desc_label.text = kw.get("description", "")
	stacks_label.text = "Stacks: %d" % stacks if stacks > 0 else ""
	stacks_label.visible = stacks > 0
	visible = true
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	match kw.get("type", ""):
		"buff":
			style.border_color = Color(0.3, 0.7, 0.3)
		"environment":
			style.border_color = Color(0.7, 0.3, 0.3)
		"mark":
			style.border_color = Color(0.5, 0.5, 0.7)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	add_theme_stylebox_override("panel", style)

func hide_tooltip():
	visible = false
```

### D.24 KeywordTooltip.tscn
```tscn
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://ui/components/KeywordTooltip.gd" id="1"]

[node name="KeywordTooltip" type="PanelContainer"]
visible = false
custom_minimum_size = Vector2(200, 80)
script = ExtResource("1")

[node name="VBox" type="VBoxContainer" parent="."]
layout_mode = 2

[node name="NameLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "关键词名"

[node name="TypeLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "类型"

[node name="DescLabel" type="Label" parent="VBox"]
layout_mode = 2
autowrap_mode = 2
text = "描述"

[node name="StacksLabel" type="Label" parent="VBox"]
layout_mode = 2
text = "层数: 0"
```

---

*文档结束。实施方按Phase 1-5顺序执行，完成后交付验收。*
