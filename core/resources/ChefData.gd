extends Resource
class_name ChefData

@export var id: String = ""
@export var name: String = ""
@export var cuisines: Array[String] = []
@export var skill_name: String = ""
@export var skill_trigger: String = ""
@export var skill_effect: Dictionary = {}
@export var skill_description: String = ""
@export var tool_slots: int = 3
@export var base_stats: Dictionary = {"flavor": 0, "technique": 0, "presentation": 0}

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name,
		"cuisines": Array(cuisines),
		"skill": {
			"name": skill_name,
			"trigger": skill_trigger,
			"effect": skill_effect.duplicate(),
			"description": skill_description
		},
		"tool_slots": tool_slots,
		"base_stats": base_stats.duplicate(),
	}

static func from_dict(data: Dictionary) -> ChefData:
	var c = ChefData.new()
	c.id = data.get("id", "")
	c.name = data.get("name", "")
	for cu in data.get("cuisines", []):
		c.cuisines.append(str(cu))
	var skill = data.get("skill", {})
	c.skill_name = str(skill.get("name", ""))
	c.skill_trigger = str(skill.get("trigger", ""))
	c.skill_effect = skill.get("effect", {}).duplicate()
	c.skill_description = str(skill.get("description", ""))
	c.tool_slots = int(data.get("tool_slots", 3))
	c.base_stats = data.get("base_stats", {}).duplicate()
	return c
