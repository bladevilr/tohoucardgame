extends Resource
class_name TechniqueData

@export var id: String = ""
@export var name: String = ""
@export var cuisine: String = ""
@export var modifiers: Dictionary = {}
@export var cd_modifier: float = 0.0
@export var added_tags: Array[String] = []
@export var restrictions: Array[String] = []
@export var description: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "cuisine": cuisine,
		"modifiers": modifiers.duplicate(),
		"cd_modifier": cd_modifier,
		"added_tags": Array(added_tags),
		"restrictions": Array(restrictions),
		"description": description,
	}

static func from_dict(data: Dictionary) -> TechniqueData:
	var t = TechniqueData.new()
	t.id = data.get("id", "")
	t.name = data.get("name", "")
	t.cuisine = str(data.get("cuisine", ""))
	t.modifiers = data.get("modifiers", {}).duplicate()
	t.cd_modifier = float(data.get("cd_modifier", 0.0))
	for tag in data.get("added_tags", []):
		t.added_tags.append(str(tag))
	for r in data.get("restrictions", []):
		t.restrictions.append(str(r))
	t.description = str(data.get("description", ""))
	return t
