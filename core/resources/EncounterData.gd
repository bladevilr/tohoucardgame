extends Resource
class_name EncounterData

@export var id: String = ""
@export var type: String = "battle"  # "battle" or "event"
@export var name: String = ""
@export var description: String = ""
@export var difficulty: int = 1
@export var reward_gold: int = 3
@export var reward_item_tier: String = "bronze"
@export var effect: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id, "type": type, "name": name, "description": description,
		"difficulty": difficulty, "reward_gold": reward_gold,
		"reward_item_tier": reward_item_tier, "effect": effect,
	}

static func from_dict(data: Dictionary) -> EncounterData:
	var e = EncounterData.new()
	e.id = data.get("id", "")
	e.type = str(data.get("type", "battle"))
	e.name = data.get("name", "")
	e.description = str(data.get("description", ""))
	e.difficulty = int(data.get("difficulty", 1))
	e.reward_gold = int(data.get("reward_gold", 3))
	e.reward_item_tier = str(data.get("reward_item_tier", "bronze"))
	e.effect = str(data.get("effect", ""))
	return e
