extends Node

# ==================== GRAND BAZAAR 风格色彩系统 ====================
# 整体风格参考：炉石传说 + 大巴扎，温暖的黄金棕褐基调

# 背景色 - 深棕色基调
const BG_PRIMARY = Color(0.08, 0.06, 0.12, 1.0)     # 深紫黑
const BG_SECONDARY = Color(0.12, 0.10, 0.18, 1.0)   # 深紫棕
const BG_PANEL = Color(0.14, 0.11, 0.20, 0.95)      # 面板背景
const BG_OVERLAY = Color(0.04, 0.03, 0.08, 0.75)    # 遮罩层

# 边框和强调色 - 黄金系
const ACCENT_GOLD = Color(0.98, 0.85, 0.28, 1.0)
const ACCENT_GOLD_DARK = Color(0.78, 0.65, 0.15, 1.0)
const ACCENT_COPPER = Color(0.89, 0.65, 0.35, 1.0)

# 品质色系 - 大巴扎标准
const TIER_BRONZE = Color(0.74, 0.56, 0.36, 1.0)
const TIER_SILVER = Color(0.80, 0.82, 0.88, 1.0)
const TIER_GOLD = Color(0.98, 0.85, 0.28, 1.0)
const TIER_DIAMOND = Color(0.52, 0.88, 1.00, 1.0)

# 料理类别颜色
const CUISINE_COLORS = {
	"ingredient": Color(0.62, 0.45, 0.28, 1.0),
	"dish": Color(0.82, 0.30, 0.32, 1.0),
	"technique": Color(0.24, 0.68, 0.76, 1.0),
	"tool": Color(0.70, 0.74, 0.78, 1.0),
	"blackmarket": Color(0.52, 0.24, 0.68, 1.0),
	"default": Color(0.50, 0.44, 0.62, 1.0)
}

# 关键词类型色
const KEYWORD_COLORS = {
	"buff": Color(0.28, 0.82, 0.42, 1.0),
	"environment": Color(0.90, 0.35, 0.32, 1.0),
	"mark": Color(0.68, 0.42, 0.90, 1.0)
}

# 功能色
const POSITIVE = Color(0.32, 0.88, 0.52, 1.0)
const WARNING = Color(0.98, 0.74, 0.25, 1.0)
const NEGATIVE = Color(0.96, 0.34, 0.34, 1.0)
const INFO = Color(0.32, 0.78, 0.92, 1.0)

# 文字颜色
const TEXT_PRIMARY = Color(0.95, 0.94, 0.92, 1.0)    # 主文本，淡黄白
const TEXT_SECONDARY = Color(0.78, 0.76, 0.72, 1.0)  # 副文本，淡金
const TEXT_DISABLED = Color(0.52, 0.50, 0.48, 1.0)   # 禁用文本
const TEXT_SHADOW = Color(0.0, 0.0, 0.0, 0.6)        # 阴影

# 按钮和UI元素
const BUTTON_NORMAL = Color(0.52, 0.42, 0.24, 0.9)
const BUTTON_HOVER = Color(0.62, 0.52, 0.32, 0.95)
const BUTTON_PRESSED = Color(0.42, 0.32, 0.14, 0.9)
const BUTTON_DISABLED = Color(0.32, 0.28, 0.24, 0.6)

# ==================== 设计系统常量 ====================

# 间距
const SPACING_XS = 4
const SPACING_SM = 8
const SPACING_MD = 12
const SPACING_LG = 16
const SPACING_XL = 24
const SPACING_2XL = 32

# 圆角
const RADIUS_SMALL = 4
const RADIUS_MEDIUM = 8
const RADIUS_LARGE = 12

# 动画时长（秒）
const ANIM_QUICK = 0.2
const ANIM_NORMAL = 0.3
const ANIM_SMOOTH = 0.5
const ANIM_SLOW = 0.8

# 字体大小（与theme.tres对应）
const FONT_SIZE_SMALL = 14
const FONT_SIZE_NORMAL = 16
const FONT_SIZE_MEDIUM = 18
const FONT_SIZE_LARGE = 24
const FONT_SIZE_TITLE = 32
const FONT_SIZE_HUGE = 48

# 透明度
const ALPHA_FULL = 1.0
const ALPHA_HEAVY = 0.9
const ALPHA_NORMAL = 0.8
const ALPHA_LIGHT = 0.6
const ALPHA_FAINT = 0.3
const ALPHA_GHOST = 0.15

# ==================== 实用函数 ====================

func get_tier_color(tier_value: Variant) -> Color:
	var tier = str(tier_value).to_lower()
	match tier:
		"0", "bronze":
			return TIER_BRONZE
		"1", "silver":
			return TIER_SILVER
		"2", "gold":
			return TIER_GOLD
		"3", "diamond":
			return TIER_DIAMOND
	return TIER_BRONZE

func get_keyword_color(keyword_type: String) -> Color:
	return KEYWORD_COLORS.get(keyword_type, TEXT_PRIMARY)

func get_merchant_color(merchant: String) -> Color:
	return CUISINE_COLORS.get(merchant, CUISINE_COLORS["default"])

# 获取半透明版本
func with_alpha(color: Color, alpha: float) -> Color:
	color.a = alpha
	return color

# 获取悬停效果色（轻微提亮）
func brighten(color: Color, amount: float = 0.15) -> Color:
	return color.lightened(amount)

# 获取禁用效果色（降低饱和度和亮度）
func desaturate(color: Color, amount: float = 0.5) -> Color:
	var gray = Color(color.get_luminance(), color.get_luminance(), color.get_luminance(), color.a)
	return color.lerp(gray, amount).darkened(0.2)
