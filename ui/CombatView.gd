extends Control

## CombatView - 战斗演出界面（MVP: 文字日志）

@onready var log_label: RichTextLabel = $VBox/LogLabel
@onready var continue_button: Button = $VBox/ContinueButton


func _ready() -> void:
	if continue_button:
		continue_button.pressed.connect(_on_continue)


func display_combat_results(results: Array) -> void:
	if log_label == null:
		return

	log_label.clear()
	log_label.push_color(GameConfig.COLOR_GOLD)
	log_label.add_text("=== 战斗结果 ===\n\n")
	log_label.pop()

	for r in results:
		var pair: Array = r.get("pair", [])
		if pair.size() < 2:
			continue
		var winner: int = r.get("winner", -1)
		var damage: int = r.get("damage", 0)

		var text: String = "玩家%d 对 玩家%d → " % [pair[0], pair[1]]
		if winner >= 0:
			text += "玩家%d 胜（扣%d 体力）" % [winner, damage]
		else:
			text += "平局"

		log_label.add_text(text + "\n")

	log_label.add_text("\n点击继续进入下一回合")


func _on_continue() -> void:
	visible = false
