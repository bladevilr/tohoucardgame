extends Resource
class_name EventData

@export var id: String = ""
@export var event_type: int = 0  # EventSystem.EventType
@export var name: String = ""
@export var description: String = ""
@export var effect: String = ""
@export var amount: int = 0
@export var items: Array[Dictionary] = []
@export var heal_amount: int = 0
@export var price_multiplier: float = 1.0

func to_dict() -> Dictionary:
	return {
		"id": id, "event_type": event_type, "name": name,
		"description": description, "effect": effect,
		"amount": amount, "items": items.duplicate(true),
		"heal_amount": heal_amount, "price_multiplier": price_multiplier,
	}

static func from_dict(data: Dictionary) -> EventData:
	var e = EventData.new()
	e.id = data.get("id", "")
	e.event_type = int(data.get("event_type", 0))
	e.name = data.get("name", "")
	e.description = str(data.get("description", ""))
	e.effect = str(data.get("effect", ""))
	e.amount = int(data.get("amount", 0))
	e.items = data.get("items", []).duplicate(true)
	e.heal_amount = int(data.get("heal_amount", 0))
	e.price_multiplier = float(data.get("price_multiplier", 1.0))
	return e
