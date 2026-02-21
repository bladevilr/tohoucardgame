extends Resource
class_name JudgeData

@export var id: String = ""
@export var name: String = ""
@export var scoring_modifiers: Dictionary = {}
@export var special_name: String = ""
@export var special_effect: Dictionary = {}
@export var description: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name,
		"scoring_modifiers": scoring_modifiers.duplicate(),
		"special": {
			"name": special_name,
			"effect": special_effect.duplicate(),
		},
		"description": description,
	}

static func from_dict(data: Dictionary) -> JudgeData:
	var j = JudgeData.new()
	j.id = data.get("id", "")
	j.name = data.get("name", "")
	j.scoring_modifiers = data.get("scoring_modifiers", {}).duplicate()
	var sp = data.get("special", {})
	j.special_name = str(sp.get("name", ""))
	j.special_effect = sp.get("effect", {}).duplicate()
	j.description = str(data.get("description", ""))
	return j
