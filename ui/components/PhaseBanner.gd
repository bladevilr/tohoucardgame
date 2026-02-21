extends CanvasLayer

# Phase banner: shows centered overlay text when phase changes, then fades out.

@onready var overlay: ColorRect = $Overlay
@onready var title_label: Label = $Overlay/VBox/TitleLabel
@onready var desc_label: Label = $Overlay/VBox/DescLabel

func _ready():
	overlay.visible = false
	layer = 100  # Above everything

func show_phase(phase: int):
	var title = ""
	var desc = ""
	match phase:
		GameConfig.Phase.SHOP:
			title = "商店阶段"
			desc = "购买食材和菜品，布置你的料理台"
		GameConfig.Phase.EVENT_CHOICE:
			var action_data = GameManager.get_current_action_data()
			title = action_data.get("name", "随机事件")
			desc = action_data.get("desc", "选择你的命运")
		GameConfig.Phase.PVE_BATTLE:
			var action_data = GameManager.get_current_action_data()
			title = action_data.get("name", "试营业")
			desc = action_data.get("desc", "检验你的料理阵容")
		GameConfig.Phase.PREP:
			title = "准备阶段"
			desc = "调整料理台排列，准备迎接对决"
		GameConfig.Phase.PVP_BATTLE:
			title = "深夜料理对决"
			desc = "月光下的终极对决，胜者为王"
		GameConfig.Phase.SHOWDOWN:
			title = "料理对决"
			desc = "30秒自动烹饪，比拼最终得分"
		GameConfig.Phase.RESULT:
			title = "对决结算"
			desc = "查看战斗分析"
		_:
			return  # Unknown phase, don't show banner

	title_label.text = title
	desc_label.text = desc
	overlay.visible = true
	overlay.modulate = Color(1, 1, 1, 0)

	# Animate: fade in → hold → fade out
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(overlay, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): overlay.visible = false)
