# **基于Godot引擎实现自走棋类游戏大巴扎视觉风格的美术资源构建与技术路径深度研究报告**

在当代游戏工业的语境下，视觉识别系统（Visual Identity）的独特性已成为产品在红海市场中脱颖而出的核心驱动力。以《大巴扎》（The Bazaar）为代表的新一代英雄构建类自走棋（Hero Builder Auto-battler），不仅在玩法上融合了Roguelike与异步PvP，更在视觉表现上确立了一种被称为“流动博物馆”的独特审美范式 1。这种风格将中东传统巴扎的市井气息与科幻天际线、蒸汽朋克技术以及超现实魔法元素深度耦合，形成了一种极具辨识度的视觉叙事 1。对于使用Godot引擎的开发者而言，如何在资源匮乏的情况下，通过科学的资源收集、高效的UI框架搭建以及高级着色器技术的应用，重现这种跨时空、高饱和度的视觉效果，是一个涉及技术美术、交互设计与系统架构的综合性命题。

## **视觉美学溯源：大巴扎的风格解构与叙事逻辑**

《大巴扎》的视觉成功并非偶然，其核心在于一种“有序的混乱”。根据N-iX Games的美术架构师所述，该作的设计目标是建立一个既统一又多元的审美体系，其背景设定在一个名为“大巴扎”的星际大都市 1。在这一设定下，视觉元素呈现出高度的冲突美学：木制的香料架旁可能斜靠着一把等离子步枪，而古老的卷轴则通过蒸汽朋克式的机械装置进行解读 1。这种风格对UI美术提出了极高的要求，即每一个UI组件本身必须具备叙事功能，而非仅仅是标准化的功能按钮 2。

在自走棋的语境下，UI是玩家感知战术反馈的首要通道。大巴扎采用了基于角色的视觉身份系统，每位英雄如炼金术士Mak或走私者Vanessa，都拥有一套独立的色彩调色板和视觉特征 1。这种设计不仅支持了游戏的叙事和货币化潜力，更在UI层面通过高度定制化的图标和布局增强了可读性 1。例如，Mak的技能面板可能充斥着流动的药水效果，而Dooley的界面则强调机器人军团的核心状态感 3。这种基于角色的UI定制化策略，意味着在Godot中构建UI时，必须跳出单一主题（Theme）的限制，转而采用一种更具扩展性的分层主题架构 4。

## **资源收集与资产流水线：从原始素材到艺术对齐**

对于独立开发者而言，重现大巴扎风格的首要挑战在于高质量手绘资源的获取。大巴扎使用了大量的分层手绘资产，这些资产在设计之初就考虑到了后续在引擎中实现的动画和视差效果 1。

### **资源获取渠道与风格筛选**

在收集美术资源时，开发者需要跨越多个平台进行精细化筛选，以寻找那些具有“手绘感”且支持分层处理的素材。

| 资源平台 | 风格优势 | 在大巴扎类项目中的应用策略 | 许可协议注意事项 |
| :---- | :---- | :---- | :---- |
| itch.io | 包含大量高质量的手绘UI包、RPG技能图标及动态角色资产 6 | 搜索“Hand-painted”、“Stylized Fantasy”或“Steampunk UI” 8 | 需仔细检查具体的创作共享协议（CC-BY vs CC0），避免法律纠纷 6 |
| Kenney Assets | 提供极度规范化的UI Pack，适合快速搭建交互原型 6 | 利用其UI Pack作为占位符，先行测试Godot的九宫格缩放逻辑 11 | 大多采用CC0协议，是极佳的商业起点 6 |
| Penzilla (itch) | 极具个人特色的手绘RPG图标、等距视角村庄资产 7 | 适合用于构建巴扎中的商店货架物品和技能图标 7 | 多为付费套件，通常包含分层的PNG图像 7 |
| Game Dev Market | 专业的2D角色、GUI及环境背景资源库 13 | 寻找包含PSD原件的GUI套件，以便进行后期分层导出 13 | 针对独立开发者友好，通常按单项资产计费 13 |
| OpenGameArt | 丰富的开源、免费纹理与矢量UI元素 14 | 寻找具有特定材质感（如旧羊皮纸、锈蚀金属）的纹理集 15 | 需关注社区贡献者的特定授权要求 14 |

### **资产的分层与动态预处理**

大巴扎风格的物品不仅仅是静态图像，它们是“多层”的。为了在Godot中实现生动的动态反馈，收集到的物品资源（如等离子步枪、魔法书）应当在Photoshop等工具中进行图层拆解 1。例如，一把具有能量核心的步枪应被拆分为底壳、发光核心、外溢能量流以及阴影层。在Godot中，这些层级可以通过多个Sprite2D或TextureRect节点进行组合，并利用补间动画（Tween）实现微小的位移偏移，产生呼吸感或能量震荡感 1。

## **Godot UI架构：基于节点的响应式系统搭建**

Godot引擎在处理此类复杂UI效果时展现出了卓越的灵活性。其核心哲学在于“一切皆节点”，这使得UI的层级结构能够完美契合大巴扎这种多层化、交互密集的界面需求 17。

### **核心布局容器的战术应用**

在自走棋的商店界面中，如何管理动态生成的物品卡牌是技术难点。Godot的布局容器（Containers）提供了自动化的解决方案。

1. **GridContainer的深度定制**：在构建大巴扎的物品货架时，GridContainer是骨架。通过设置columns属性，它可以自动排列玩家在每一轮刷新的商品 19。然而，标准的GridContainer在处理不同宽高比的卡牌时可能会出现对齐问题，因此通常需要配合AspectRatioContainer来保证卡牌的视觉完整性 20。  
2. **ScrollContainer的交互优化**：自走棋中常有大量的英雄技能或历史战绩。利用ScrollContainer结合手柄/鼠标滚轮的支持，可以实现平滑的内容切换 20。在大巴扎中，这种滚动通常伴随着背景的模糊效果，以突出当前活动区域 1。  
3. **PanelContainer与九宫格切片**：为了让手绘边框适应不同尺寸的提示框，NinePatchRect或内置在StyleBoxTexture中的九宫格逻辑至关重要 23。通过定义纹理的四个角不缩放，而中间部分平铺或拉伸，开发者可以利用极小的纹理资源生成任意尺寸且不失真的高质量面板 23。

### **响应式设计的数学模型与实现**

大巴扎作为一个PC平台首发的项目，必须考虑不同纵横比的适配 18。在Godot中，这涉及到项目设置中的拉伸策略（Stretch Settings）。 当窗口缩放时，UI坐标系的变化可以描述为：

![][image1]  
其中，$P\_{base}$是预设分辨率下的位置，$S\_{viewport}$是视口缩放系数，$O\_{anchor}$是由锚点定义的偏移量 18。 通过将拉伸模式设置为canvas\_item并将长宽比设置为expand，Godot允许UI在超宽屏下显示更多的侧边背景元素（如巴扎的街景），而在标准屏下保持核心交互区居中 17。为了确保UI不随主摄像机移动而偏移，必须使用CanvasLayer作为UI根节点，将其从世界空间的坐标变换中解耦 20。

## **高级视觉特效：着色器编程实现艺术升华**

大巴扎最引人入胜的视觉效果——如卡牌的流光、背景的磨砂玻璃感、物品的边缘发光——几乎全部依赖于GPU着色器的实时处理。Godot的着色器语言（GDShader）基于GLSL，但在UI应用上进行了特定优化 26。

### **磨砂玻璃（Glassmorphism）与屏幕空间采样**

在UI界面中，为了让半透明的面板既能透出背景色彩又不会干扰文字阅读，磨砂玻璃效果是最佳方案 22。其核心逻辑是利用hint\_screen\_texture对UI下方的屏幕内容进行多级渐进采样（LOD Sampling） 22。

OpenGL Shading Language

shader\_type canvas\_item;  
uniform sampler2D screen\_texture : hint\_screen\_texture, filter\_linear\_mipmap;  
uniform float blur\_amount : hint\_range(0.0, 5.0) \= 2.0;

void fragment() {  
    // 使用纹理LOD实现低成本模糊  
    vec4 blur\_sample \= textureLod(screen\_texture, SCREEN\_UV, blur\_amount);  
    // 叠加一层暗色调以增强对比度  
    vec4 overlay \= vec4(0.1, 0.1, 0.1, 0.4);  
    COLOR \= mix(blur\_sample, overlay, overlay.a);  
    // 限制在UI组件的Alpha范围内  
    COLOR.a \*= texture(TEXTURE, UV).a;  
}

这种技术的优势在于，利用预计算的Mipmap纹理，其计算开销是恒定的，不会随模糊半径的增大而线性增加，这对于复杂的自走棋战斗场景非常友好 22。

### **卡牌光泽与动态边缘效果**

大巴扎中高稀有度卡牌划过的金属光泽，可以通过正弦波函数结合UV偏移来实现 27。光带的位置随时间![][image2]变化的公式可表达为：

![][image3]  
其中，![][image4]是光带速度，![][image5]是光带宽度 27。 此外，对于重叠的UI元素，使用CanvasGroup节点配合边缘检测着色器，可以生成统一的外部描边，解决多个子节点重叠时描边错乱的问题 31。这种处理方式能够模拟出大巴扎中英雄头像被高亮选中的视觉仪式感 31。

## **交互的灵魂：补间动画与动态反馈**

“果汁感”（Juiciness）是评价一款现代UI是否成功的关键指标。大巴扎中那种灵动的、反馈极其迅速的交互体验，主要通过Godot的补间动画（Tween）系统实现 33。

### **Tween系统在UI反馈中的高级逻辑**

相比传统的AnimationPlayer，Tween系统在处理UI位置微调和缩放反馈时更具优势，因为它能在代码运行时动态获取当前属性值，从而实现无缝过渡 33。

| 交互类型 | 推荐的补间参数（Transition/Ease） | 心理暗示与视觉效果 |
| :---- | :---- | :---- |
| 卡牌选中/放大 | TRANS\_ELASTIC, EASE\_OUT 35 | 模拟物理弹簧感，传递出轻快、生动的反馈 35 |
| 商店物品售出/消失 | TRANS\_BACK, EASE\_IN 33 | 物品在消失前会有微小的后撤，产生动作势能感 |
| 属性值（金币/生命）增长 | TRANS\_SINE, EASE\_IN\_OUT 33 | 视觉上比线性变化更柔和，符合自然界规律 33 |
| 面板切入/滑出 | TRANS\_QUINT, EASE\_OUT 16 | 快速起步、平滑减速，强调界面层级的瞬时性 16 |

### **解决UI缩放带来的模糊问题**

在自走棋中，玩家经常需要放大查看卡牌细节。Godot的一个常见问题是直接缩放Control节点会导致文字变得模糊 37。专业实践是：

1. **字体大小补间**：不直接缩放节点，而是利用tween\_method动态改变字体的font\_size属性，确保每一帧都进行高质量的矢量渲染 37。  
2. **MSDF字体技术**：开启多通道有向距离场（MSDF）字体支持，这使得文本在极端缩放比例下依然能保持锐利的边缘，这对于需要展示复杂说明的大巴扎式卡牌至关重要 16。

## **3D与2D的融合：构建交互式场景与物品**

大巴扎的成功不仅在于UI，更在于其精致的交互式3D棋盘和动态展示的物品模型 1。在Godot中实现这种跨维度的视觉集成，核心技术是SubViewport 39。

### **场景嵌入式物品展示**

在自走棋的商店或英雄库中，实时展示3D物品模型（如缓缓旋转的法杖）能显著提升玩家的获得感 41。

1. **隔离渲染环境**：通过配置SubViewport并开启Own World 3D，开发者可以为UI物品创建独立的光照环境，而不受主战斗场景灯光的影响 40。  
2. **背景透明化处理**：设置transparent\_bg \= true，使得渲染出的3D模型能完美悬浮在手绘风格的UI背景之上，实现2D与3D的无缝视觉融合 39。  
3. **视差位移映射**：对于追求极致表现的移动端项目，若3D模型开销过大，可采用视差映射着色器（Parallax Mapping Shader）。通过一张法线贴图和一张深度图，在平面UI纹理上模拟出随视角变化的深度错觉，重现大巴扎卡牌中的“立体感” 42。

### **动态棋盘的点击反馈**

大巴扎的棋盘包含许多可点击的交互“小玩具” 1。在Godot中，开发者可以通过将射线检测（Raycasting）与UI输入系统结合，使得玩家在点击UI背景时能触发3D场景中的动画反馈，这种维度的穿插能极大地提升游戏的沉浸感 1。

## **工程化挑战：大型UI系统的一致性维护**

随着英雄数量和物品种类的增加，UI的维护成本呈几何倍数增长。Godot的Theme系统是解决这一问题的终极武器 5。

### **基于主题的全局样式管控**

大巴扎采用了严谨的色彩编码系统（如英雄专属色调）。开发者应当建立一个全局的.theme资源，并将其绑定到项目设置中的gui/theme/custom路径下 5。

* **类型变体（Type Variations）**：为不同稀有度的卡牌定义不同的按钮变体（如LegendaryButton、EpicButton）。当美术资源更新时，只需在Theme编辑器中修改对应的StyleBoxTexture，全场景数以百计的按钮将同步更新样式 4。  
* **代码控制主题属性**：利用ThemeDB或节点自带的add\_theme\_\*\_override方法，可以在运行时根据英雄状态（如狂暴模式）动态改变界面的边框颜色或发光强度，实现视觉上的即时反馈 4。

### **场景组织与重构工作流**

在大巴扎的开发历程中，核心玩法经历了多次重大转向（Pivot），从回合制变为异步自走棋 1。这种不确定性要求UI结构必须具备极高的可维护性。

* **Scene Unique Names (%)**：利用Godot 4的场景唯一名称功能，脚本可以跨越层级访问节点（如%GoldLabel），而无需关心UI层级结构的重排 18。  
* **UID系统**：启用Godot的文件UID支持，确保即使在对项目目录进行大规模重组（如将所有巴扎相关的资源移入独立目录）时，场景间的引用链接依然稳固 47。

## **结论：技术与艺术的协同进化**

实现类大巴扎的UI视觉效果，本质上是在Godot引擎中建立一套“技术美术流水线”。它始于对跨文化视觉元素的敏锐捕捉与收集，通过精心挑选的手绘资产建立世界观的厚度 1；它中继于Godot强大的容器布局与响应式系统，确立了跨平台交互的稳定性 17；它升华于高级着色器技术与补间动画的精密配合，赋予了界面如同生命体般的动态反馈与艺术张力 16。

随着异步PvP自走棋类游戏的竞争进入下半场，UI不再仅仅是数据的显示器，而是情感的传递介质。大巴扎风格的成功揭示了这样一个真理：当开发者能够利用Godot这种开源引擎的底层逻辑，将复杂的数学着色逻辑与细腻的人文艺术表达深度对齐时，即使是有限的资源也能激发出无限的视觉生命力 1。未来的UI设计将进一步模糊2D与3D、界面与世界的界限，而Godot提供的Viewport集成与高度可扩展的主题系统，正是通往这一目标的必经之路 5。

#### **Works cited**

1. The Bazaar: a Development Story \- N-iX Games, accessed February 15, 2026, [https://gamestudio.n-ix.com/case-study/the-bazaar-game-development-story/](https://gamestudio.n-ix.com/case-study/the-bazaar-game-development-story/)  
2. What are your top 3 likes and dislikes about The Bazaar? : r/PlayTheBazaar \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/PlayTheBazaar/comments/1ixzh2i/what\_are\_your\_top\_3\_likes\_and\_dislikes\_about\_the/](https://www.reddit.com/r/PlayTheBazaar/comments/1ixzh2i/what_are_your_top_3_likes_and_dislikes_about_the/)  
3. A Very Lively Marketplace (The Bazaar — A Game Review) | by Apollo | Medium, accessed February 15, 2026, [https://medium.com/@819apollo/a-very-lively-marketplace-the-bazaar-a-game-review-d25f99716d88](https://medium.com/@819apollo/a-very-lively-marketplace-the-bazaar-a-game-review-d25f99716d88)  
4. In-depth tutorials about UI theming \- UI \- Godot Forum, accessed February 15, 2026, [https://forum.godotengine.org/t/in-depth-tutorials-about-ui-theming/125725](https://forum.godotengine.org/t/in-depth-tutorials-about-ui-theming/125725)  
5. Theme — Godot Engine (stable) documentation in English, accessed February 15, 2026, [https://docs.godotengine.org/en/stable/classes/class\_theme.html](https://docs.godotengine.org/en/stable/classes/class_theme.html)  
6. Where To Find Game Assets : Open Game Art Alternatives \- MAGES Institute, accessed February 15, 2026, [https://mages.edu.sg/blog/where-to-find-game-assets-open-game-art-alternatives/](https://mages.edu.sg/blog/where-to-find-game-assets-open-game-art-alternatives/)  
7. Penzilla \- itch.io, accessed February 15, 2026, [https://penzilla.itch.io/](https://penzilla.itch.io/)  
8. Fantasy UI Pack – 50+ Elements for Unity, Godot, & RPGs : r/indiegames \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/indiegames/comments/1mc2xtg/fantasy\_ui\_pack\_50\_elements\_for\_unity\_godot\_rpgs/](https://www.reddit.com/r/indiegames/comments/1mc2xtg/fantasy_ui_pack_50_elements_for_unity_godot_rpgs/)  
9. Game assets? What is the most needed? : r/itchio \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/itchio/comments/1qnfjm0/game\_assets\_what\_is\_the\_most\_needed/](https://www.reddit.com/r/itchio/comments/1qnfjm0/game_assets_what_is_the_most_needed/)  
10. Where I actually find free game assets (compiled my go-to sources) : r/gamedev \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/gamedev/comments/1qhuwg8/where\_i\_actually\_find\_free\_game\_assets\_compiled/](https://www.reddit.com/r/gamedev/comments/1qhuwg8/where_i_actually_find_free_game_assets_compiled/)  
11. Best "complete" asset packs you know of? : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1ahft38/best\_complete\_asset\_packs\_you\_know\_of/](https://www.reddit.com/r/godot/comments/1ahft38/best_complete_asset_packs_you_know_of/)  
12. NinePatch Buttons? : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/8qgkok/ninepatch\_buttons/](https://www.reddit.com/r/godot/comments/8qgkok/ninepatch_buttons/)  
13. GameDev Market: Game Assets for Indie Developers, accessed February 15, 2026, [https://www.gamedevmarket.net/](https://www.gamedevmarket.net/)  
14. OpenGameArt.org |, accessed February 15, 2026, [https://opengameart.org/](https://opengameart.org/)  
15. UI Pack \- OpenGameArt.org |, accessed February 15, 2026, [https://opengameart.org/content/ui-pack](https://opengameart.org/content/ui-pack)  
16. Trying to make a pleasing a juicy UI : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1ov9qkr/trying\_to\_make\_a\_pleasing\_a\_juicy\_ui/](https://www.reddit.com/r/godot/comments/1ov9qkr/trying_to_make_a_pleasing_a_juicy_ui/)  
17. Godot's ui system is amazing \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1oerwcx/godots\_ui\_system\_is\_amazing/](https://www.reddit.com/r/godot/comments/1oerwcx/godots_ui_system_is_amazing/)  
18. \[Godot 4\] How to structure classic UI layout around a central board \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1l9rtfu/godot\_4\_how\_to\_structure\_classic\_ui\_layout\_around/](https://www.reddit.com/r/godot/comments/1l9rtfu/godot_4_how_to_structure_classic_ui_layout_around/)  
19. GridContainer — Godot Engine (4.4) documentation in English, accessed February 15, 2026, [https://docs.godotengine.org/en/4.4/classes/class\_gridcontainer.html](https://docs.godotengine.org/en/4.4/classes/class_gridcontainer.html)  
20. Overview of Godot UI containers \- GDQuest School, accessed February 15, 2026, [https://school.gdquest.com/courses/learn\_2d\_gamedev\_godot\_4/start\_a\_dialogue/all\_the\_containers](https://school.gdquest.com/courses/learn_2d_gamedev_godot_4/start_a_dialogue/all_the_containers)  
21. Godot UI Layout Tutorial \- YouTube, accessed February 15, 2026, [https://www.youtube.com/watch?v=mbyI5yziX-Q](https://www.youtube.com/watch?v=mbyI5yziX-Q)  
22. Bringing "Frosted Glass" to our UI : r/gamedevscreens \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/gamedevscreens/comments/1r0ylar/bringing\_frosted\_glass\_to\_our\_ui/](https://www.reddit.com/r/gamedevscreens/comments/1r0ylar/bringing_frosted_glass_to_our_ui/)  
23. NinePatchRect — Godot Engine (3.3) documentation in English, accessed February 15, 2026, [https://docs.godotengine.org/en/3.3/classes/class\_ninepatchrect.html](https://docs.godotengine.org/en/3.3/classes/class_ninepatchrect.html)  
24. StyleBoxTexture — Godot Engine (3.3) documentation in English, accessed February 15, 2026, [https://docs.godotengine.org/en/3.3/classes/class\_styleboxtexture.html](https://docs.godotengine.org/en/3.3/classes/class_styleboxtexture.html)  
25. Godot UI Basics \- how to build beautiful interfaces that work everywhere (Beginners), accessed February 15, 2026, [https://www.youtube.com/watch?v=1\_OFJLyqlXI](https://www.youtube.com/watch?v=1_OFJLyqlXI)  
26. Blur Shader in Godot 4.5 \- YouTube, accessed February 15, 2026, [https://www.youtube.com/watch?v=Z2o6IfmK61A](https://www.youtube.com/watch?v=Z2o6IfmK61A)  
27. 2D Shader for Shine Effect? And understanding how it works? : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/10zsdjd/2d\_shader\_for\_shine\_effect\_and\_understanding\_how/](https://www.reddit.com/r/godot/comments/10zsdjd/2d_shader_for_shine_effect_and_understanding_how/)  
28. Bringing "Frosted Glass" to our UI : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1r0wltf/bringing\_frosted\_glass\_to\_our\_ui/](https://www.reddit.com/r/godot/comments/1r0wltf/bringing_frosted_glass_to_our_ui/)  
29. More of my glass shader in action : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1plj2ec/more\_of\_my\_glass\_shader\_in\_action/](https://www.reddit.com/r/godot/comments/1plj2ec/more_of_my_glass_shader_in_action/)  
30. 2D Practice Shaders in Godot: Four New Effects \- YouTube, accessed February 15, 2026, [https://www.youtube.com/watch?v=S9\_-ltseSOk](https://www.youtube.com/watch?v=S9_-ltseSOk)  
31. Need a shader for UI Outlining \- Godot Forum, accessed February 15, 2026, [https://forum.godotengine.org/t/need-a-shader-for-ui-outlining/115629](https://forum.godotengine.org/t/need-a-shader-for-ui-outlining/115629)  
32. Use particle emission shapes to give effects to your UI : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1e4puwo/use\_particle\_emission\_shapes\_to\_give\_effects\_to/](https://www.reddit.com/r/godot/comments/1e4puwo/use_particle_emission_shapes_to_give_effects_to/)  
33. Change my mind: Tween is the best tool in Godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1qhz66f/change\_my\_mind\_tween\_is\_the\_best\_tool\_in\_godot/](https://www.reddit.com/r/godot/comments/1qhz66f/change_my_mind_tween_is_the_best_tool_in_godot/)  
34. Godot Tweens can make GUI animations feel so good \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1o3qu41/godot\_tweens\_can\_make\_gui\_animations\_feel\_so\_good/](https://www.reddit.com/r/godot/comments/1o3qu41/godot_tweens_can_make_gui_animations_feel_so_good/)  
35. Fun with tweens to create a juicy button \- godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1k9y42c/fun\_with\_tweens\_to\_create\_a\_juicy\_button/](https://www.reddit.com/r/godot/comments/1k9y42c/fun_with_tweens_to_create_a_juicy_button/)  
36. 10 Tricks for Tweens and AnimationPlayers \- Godot Tutorial \- YouTube, accessed February 15, 2026, [https://www.youtube.com/watch?v=iFJtXrwacY0](https://www.youtube.com/watch?v=iFJtXrwacY0)  
37. Fast clicking a button with Tween animation problem \- Programming \- Godot Forum, accessed February 15, 2026, [https://forum.godotengine.org/t/fast-clicking-a-button-with-tween-animation-problem/106991](https://forum.godotengine.org/t/fast-clicking-a-button-with-tween-animation-problem/106991)  
38. Animating UI nodes \- General \- Godot Forum, accessed February 15, 2026, [https://forum.godotengine.org/t/animating-ui-nodes/127305](https://forum.godotengine.org/t/animating-ui-nodes/127305)  
39. Godot 4 Sub-Viewport Tutorial \- YouTube, accessed February 15, 2026, [https://www.youtube.com/watch?v=K\_mZeYLYpgg](https://www.youtube.com/watch?v=K_mZeYLYpgg)  
40. How to display 3D object in 2D UI (with SubViewport node) \- Tips & Tricks \- Godot Forum, accessed February 15, 2026, [https://forum.godotengine.org/t/how-to-display-3d-object-in-2d-ui-with-subviewport-node/128976](https://forum.godotengine.org/t/how-to-display-3d-object-in-2d-ui-with-subviewport-node/128976)  
41. Using subviewports to add a third dimension to my game's shop : r/godot \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/godot/comments/1i4bcuj/using\_subviewports\_to\_add\_a\_third\_dimension\_to\_my/](https://www.reddit.com/r/godot/comments/1i4bcuj/using_subviewports_to_add_a_third_dimension_to_my/)  
42. Godot Card Parallax \- Godot Asset Library, accessed February 15, 2026, [https://godotengine.org/asset-library/asset/2560](https://godotengine.org/asset-library/asset/2560)  
43. Ice Lake Visual Shader \- Parallax Mapping In Godot 4 \- YouTube, accessed February 15, 2026, [https://www.youtube.com/watch?v=rJ3SLRs35wg](https://www.youtube.com/watch?v=rJ3SLRs35wg)  
44. Godot 4 Autobattler Tutorial: UnitMover (S1E5) \- YouTube, accessed February 15, 2026, [https://www.youtube.com/watch?v=ZksnCGmBLI8](https://www.youtube.com/watch?v=ZksnCGmBLI8)  
45. The Godot Barn \~ Articles / Set a project-wide custom theme, accessed February 15, 2026, [https://thegodotbarn.com/contributions/article/30/set-a-project-wide-custom-theme](https://thegodotbarn.com/contributions/article/30/set-a-project-wide-custom-theme)  
46. The Bazaar, its current path, and designing around the strengths of a genre : r/PlayTheBazaar \- Reddit, accessed February 15, 2026, [https://www.reddit.com/r/PlayTheBazaar/comments/nkwm6l/the\_bazaar\_its\_current\_path\_and\_designing\_around/](https://www.reddit.com/r/PlayTheBazaar/comments/nkwm6l/the_bazaar_its_current_path_and_designing_around/)  
47. Godot code style, project structure and friends \- Simon Dalvai, accessed February 15, 2026, [https://simondalvai.org/blog/godot-best-practices/](https://simondalvai.org/blog/godot-best-practices/)  
48. Scene organization — Godot Engine (4.4) documentation in English, accessed February 15, 2026, [https://docs.godotengine.org/en/4.4/tutorials/best\_practices/scene\_organization.html](https://docs.godotengine.org/en/4.4/tutorials/best_practices/scene_organization.html)  
49. Enhanced UI Styling System with Godot Style Sheet \#13269 \- GitHub, accessed February 15, 2026, [https://github.com/godotengine/godot-proposals/issues/13269](https://github.com/godotengine/godot-proposals/issues/13269)

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAATUAAAA5CAYAAABXqrzLAAAJpUlEQVR4Xu2cfajlRRnHHzFFzfV9S/Gla4YiGZJl4a6rK5ToH0poomEJZqmhBrVYllJ3EfEVfGlXy7dFIRKVDESUFD2oYKBkxaZSCCq1omJRUKhRNh+e3+OZ+9zffTn3nHvvOXu+H3i458zM75yZZ2aeeZ6ZOddMCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgixTHy0yD5J9pxSYnzZztp1s01daEQ5uMj6IncVWdekfbjIjz8oIQbBrkXuKPJSkY1FVk3NFoPm40Xen0M+b1vHJO4VdPO6TddHLU/aaOpmb/P6P2pu2DYXOaPIrUU63WKiT+4t8r8iPyzy5SLPm+v9yLqQGDxMyp8X+UuR/Vry6IR/pfRxAt2ggzbdbDDXzWdS3jCDId6SEwu/MW/nKTljDNklJ/TIT811uUfOsO6cYiERi8ReRf5Y5KEiO6Q8CK9kXEE3tL9NN983z/tuzhhiqO8VOdE87e0ih+aMMYR+XShsWaDjx3JGxd9tvOfUonOmuYK/kDPMJ/K4GzXaTgiRQTcsBOQTuo0C7AlS3wtzRuGmRsTCjdqaIu8WucFm35bomPcD+9liEbjdXME5vILDTK4y7Sc0z6AbVlx085GUN6yEUXs5ZxR2s3ZvdBxZqFHrmOuXsTEbHfNy9IdYBP5p7Z7Yj8zTT8wZQwSrYT6dnEt64XBzHbDRW7Njk/6PlD4K/Ne63jfC+6unlBALMWofsq5O5+Lf5uXY+hGLQHQEJ18h7AeQtqkqN4ywoftaj9ILEZr/2qbq5j1z3bR5t8PO6ebGuDZsCHtBwlmIUSOURI84CXMROscQigGzu7lyn8oZs8CdpgeKPGjusQRfaqRfwnNc7lAI3TxrrpsVKa/mTnNvBwO41PTiHcxEnO72ctixusjZOXEEudmmLuYhz7WkISv9sVZOMtdjJ6Vn4hpV25bGoLjOeu/TrQauItD4XjaI6YyLzK8AcLEwwBixcd4vcT9suUE3XNeYj27Os+W51tGLUcMQcbk2w2knp569eCfsyXEqPGywt/l4TpyFQRo1DtroBy4zz0acmF+eMwYMV3OOzonjQIRXvdxNwnh92qb/6mCtDWaPgMHxXk5cBuarG/b1Npl7dssBVzF+kBNb+J35gpFhn/FV683TXFXkYzlxCBjU2OnFwAfhINyfMyr2L/JnW5rDJRbjfXPi1k7cT+sU2XlqVisYsYOKPFHkwCLbVnl0Vn1hkdekwWfNXfMMXt7xNv3oG29vvh7fYh4UxP20uXQTHh1/czvREW1s85Ci/XlxIOxe25LeL3i/bUbtq+btrPuB764PiFjxY8+NvDY9Um/aX9ebz6jfx2ccY751wTiJ70FH6LAeV9Rpwrx8PEt+lEN/HObwGiPBLyQYn5zk9sNCjFpcquVEfCbYpkDymAfaV7cTav2Qjn7broFMmG/9hO7C+6Ysz7Ttl9JfPBPzlDrF9/N3JL28XsIruMx8/yVc89hPw5PB5f69+QDGCPzMPEz9WpFzi1xqU+/BoTjCV7yD3xb5U5XH5Gu7HLrUoJv5hHWEntxjY//iYnMjDvy2kjaeZb5w5P0N9uvIo8wnmzQmNh7VOUWertL7hT6hLW0eHbqv9Q/3FbmkyCHNe55lctE29lM5cIk8YAxRb9pDvYFxwakq4wLwGkIHfB59v9H8ZPkqcw8HYWwFzxS5rci15uME2Pp4wfz3lN8s8gfziXm9eT8wPhlzbYZjvizEqMFbNn2BAN6fZu5FoqPMsebtuMC8zWHImEfrzefRg+bzKJ+4M87QET/Dutt8S+Jkc+N5i/kdSp6t978Zp/QXfUD/UD+M35NFflXkWzb75eGhI2L6LG0rQKYtTv+GudfxC3OFMtBYKf5T5LimDO9jQIcxDdifqQ3rTB7FUpH1glDHmcA4bWpeYzw65p4CRv3AJp22o4MAHTAp8XzXmhv58617yZdV9Jc2dc+yHxjk3J36tvlgJwR6xfz7Jj4o5WAgqA/9Gd/PpMEjYlLFghR51DsuHzNhqTfG7ytNOT4HWKjitBh9sch9zrxuseAxthg3ocfw8uI9HgTjDd3yeUxoDFgwqLGzUKMGGCjGzF/NDTR7fG8W+XpdqIK21frk3mhs4zBmmHP1PMIDCzrmzwJGa3WVzuITMH5jfvN5eOcBxuxs877lUIyFhd8GY2DHAlbVtmsMR9n0W/WEb9E55IUxxIAxcIN3zQc2MJkJPfk7KmCg8daACcUKd4T54MDII7yuw1hCpTCYa5o0nuM9/80Bg1evrP1CmBYwiOmDdTbdoAUYYwxHwOSMviRvsnmNZ0m9t5jXG2+hrjf3sej73K94aHhugHGK1+gRHWDkwsBDbJWEDvF4as8f8nf0Qz9GDTA+3zPXG22qQ+oM7YjIJE7ca0+PvqrnEfMlQEdtUU198IPOYiyGjmrDT/1i24TnYiyPBTGwMqwAL5orjDABas8sJgiD/UrzVSRcWxTN6rBHkQPMOxhhtRsVXjXfY2IgbijyCfNBEiFEeB8Y/u+Ye7J4S0FMRPRwV5WOR7R99X4pYULQroC6A334iHl9WeBW2PTrQNQ7II8y2Ts/vfmbT7oZJ4RMjJ26PD87IrSDmYwX4yZ0TojaD/mzFxN0jRcMhIMsBOjnVJvumaGfSfN5hBeLjtBtwCLDOHzFugvFpPkc/KL5XK2jDrY30GsY0doRGQuygoMTirxj/i+K1jdpdZjKBKejUCoTgYnfafLoOCYySmcgMZgxCtc0+aMAoRyTk1AqJiihXnifGHAGH+49E4/wAq8GWEUjFJg0X6UDQrQc6i8V9AMTCGgXiw98ynwjfKLIjU3apHVPflmcIhQH2kMebcQDAyZjhJXoKNKZWJvNT1WZqH9r0gG9MqaASKHNO8HDoB8I4/iMUYH5E4aJvU0Wk59YN/Ssoxrm0ZHW/YXLG9YNTdEf/x1kpXU9swjbdzLvL9IYf+FN31Pk4eY1i088NzagyDZPDVidaxc7r3Q5n9cRSrD/lEOz2dz1YYT65zqTFsf2be2fqZ14fVl/ywGTBOMTq3hAnWtvDOjDthPR/Bl4CvWzHXOvizL1GAj4zJzO9+c6Beg0120UQH9h6On7aB+v6/bTtuxJUabWMX/zuMo6pHy+UtL23FYLqx5hBFYcL0uIQYEH1u/+lRA9g7vPalpvNgvRL+dY96a+EEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghhBBCCCGEEEIIIYQQQgghRB/8Hxs7AQwWNoMfAAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAcAAAAaCAYAAAB7GkaWAAAAh0lEQVR4XmNgGLaAEYjDgJgVXQIEooF4DxBzo0uAdM0H4lZ0CRAQBOLTQOyHLAgy6j8WzAOS5ABiSQaIkSBBEBuE4UATiN9CMQYA2QPSBbITA4CcD5IE2Y8BngPxVyA2hvJB7oADkK6rQCzCAPFvM7rkUqgEyN5gZMntQPwXiJ8CcQRU0RADADPcG4p8yKkfAAAAAElFTkSuQmCC>

[image3]: <data:image/png;base64,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>

[image4]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAZCAYAAAAIcL+IAAAAm0lEQVR4XmNgGAWDH4hDMTJwBmJJZIHdQMwPxF+B+CpUTASI/wPxQ5gikCm2UDZIAqYQBN4zICl0AWIeIGZhgCicApMAgvlAfBiJDwbpQHwaiAWRxLYCcTQSn4EDKjgJWZABolEJWcCYAeIREA0DIM+5IvHBQBOI3zKgKowBYlYkPhzIMEA88wyIrzFANOMEwkBsBcTM6BLDCgAA82gXjAOWir8AAAAASUVORK5CYII=>

[image5]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABUAAAAZCAYAAADe1WXtAAABL0lEQVR4Xu2UPy9EURDFR/yJDQpRiFa2USm0oqLUqH0AvYgPsPQ6tZJOodHYD6CkVEi0GomGBOfkzsS84+W57Sb7S06yb87O3HlzJ89szEgxJ8+L0KRrQbwuZvLDt+gNWoe2oa8Wf6+k2arE+d8Gm24cqwGerXg3aoAN6FGDAU0mXqgBXqx4Q4mTS+hQg8GKtXfThz7cY8eZefsdRStRdJhiE9AZdOeeFt2HehJrwFM18Ro6sDISeu/JG1g5sJNZ+1v01sphp+59Ju/eymj+hYlcJ7IE7fhvbkSsDZn2WBVM4q6xA3YS7LpHsXO+QTWRyFlxZkEuysvhrKuJRF5OhjvMS6J3Dk017W6iKOeZWYNe3au6nAy7udIgWIaeoAc1ajix8pFQuG5H0JYaY0aYH3RlURy01HiMAAAAAElFTkSuQmCC>