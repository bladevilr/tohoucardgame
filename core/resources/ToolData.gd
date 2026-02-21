extends Resource
class_name ToolData

@export var id: String = ""
@export var name: String = ""
@export var tier: String = "bronze"
@export var category: String = "tool"
@export var core_effect: Dictionary = {}
@export var triggers: Array[Dictionary] = []
@export var description: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "tier": tier, "category": category,
		"core_effect": core_effect.duplicate(),
		"triggers": triggers.duplicate(true),
		"description": description,
	}

static func from_dict(data: Dictionary) -> ToolData:
	var t = ToolData.new()
	t.id = data.get("id", "")
	t.name = data.get("name", "")
	t.tier = str(data.get("tier", "bronze"))
	t.category = str(data.get("category", "tool"))
	t.core_effect = data.get("core_effect", {}).duplicate()
	t.triggers = data.get("triggers", []).duplicate(true)
	t.description = str(data.get("description", ""))
	return t
