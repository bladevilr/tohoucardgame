extends PanelContainer

## PlayerHUD - 顶部：体力/金币/回合

@onready var hp_label: Label = %HPLabel
@onready var gold_label: Label = %GoldLabel
@onready var round_label: Label = %RoundLabel
@onready var hp_bar: ProgressBar = %HPBar


func _ready() -> void:
	SignalBus.player_hp_changed.connect(_on_player_hp_changed)
	SignalBus.gold_changed.connect(_on_gold_changed)
	SignalBus.round_started.connect(_on_round_started)


func update_display(player: RefCounted, round_number: int) -> void:
	if player == null:
		return
	hp_label.text = "体力: %d/%d" % [player.hp, GameConfig.STARTING_HP]
	hp_bar.max_value = GameConfig.STARTING_HP
	hp_bar.value = player.hp
	gold_label.text = "金币: %d" % player.gold
	round_label.text = "回合 %d/%d" % [round_number, GameConfig.MAX_ROUNDS]


func _on_player_hp_changed(player_index: int, new_hp: int) -> void:
	if player_index != 0:
		return
	hp_label.text = "体力: %d/%d" % [new_hp, GameConfig.STARTING_HP]
	hp_bar.value = new_hp


func _on_gold_changed(player_index: int, new_gold: int) -> void:
	if player_index != 0:
		return
	gold_label.text = "金币: %d" % new_gold


func _on_round_started(round_number: int) -> void:
	round_label.text = "回合 %d/%d" % [round_number, GameConfig.MAX_ROUNDS]
