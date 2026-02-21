extends Resource
class_name IngredientData

## Unique identifier (e.g. "garlic", "chili_oil")
@export var id: String = ""
## Display name (e.g. "极品大蒜")
@export var name: String = ""
## English name
@export var name_en: String = ""
## Flavor text / description
@export var description: String = ""
## Tier: 0=Bronze, 1=Silver, 2=Gold, 3=Diamond
@export_range(0, 3) var tier: int = 0
## Shop cost (1-2 gold typically)
@export var cost: int = 1
## Stat modifiers applied to the target dish (e.g. {"flavor": 5, "aroma": 3})
@export var stat_modifiers: Dictionary = {}
## Tags added to the target dish (e.g. ["spicy", "rich"])
@export var added_tags: Array[String] = []
## Tags removed from the target dish (e.g. ["light"])
@export var removed_tags: Array[String] = []
## Restrictions: dish must have one of these tags to accept (empty = no restriction)
@export var requires_tags: Array[String] = []
## Restrictions: dish must NOT have these tags
@export var forbidden_tags: Array[String] = []
## Special effect ID (for unique ingredients with non-stat effects)
@export var special_effect: String = ""
## Cuisine affinity - bonus when applied to matching cuisine dish
@export var cuisine_affinity: String = ""
## Bonus multiplier when cuisine matches (e.g. 1.5 = 50% more effective)
@export var affinity_bonus: float = 1.5
## Rarity flavor text shown on hover
@export var flavor_text: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "name_en": name_en,
		"description": description, "tier": tier, "cost": cost,
		"item_type": "ingredient",
		"stat_modifiers": stat_modifiers.duplicate(),
		"added_tags": Array(added_tags),
		"removed_tags": Array(removed_tags),
		"requires_tags": Array(requires_tags),
		"forbidden_tags": Array(forbidden_tags),
		"special_effect": special_effect,
		"cuisine_affinity": cuisine_affinity,
		"affinity_bonus": affinity_bonus,
		"flavor_text": flavor_text,
	}

static func from_dict(data: Dictionary) -> IngredientData:
	var d = IngredientData.new()
	d.id = data.get("id", "")
	d.name = data.get("name", "")
	d.name_en = data.get("name_en", "")
	d.description = str(data.get("description", ""))
	d.tier = int(data.get("tier", 0))
	d.cost = int(data.get("cost", 1))
	d.stat_modifiers = data.get("stat_modifiers", {}).duplicate()
	for t in data.get("added_tags", []):
		d.added_tags.append(str(t))
	for t in data.get("removed_tags", []):
		d.removed_tags.append(str(t))
	for t in data.get("requires_tags", []):
		d.requires_tags.append(str(t))
	for t in data.get("forbidden_tags", []):
		d.forbidden_tags.append(str(t))
	d.special_effect = str(data.get("special_effect", ""))
	d.cuisine_affinity = str(data.get("cuisine_affinity", ""))
	d.affinity_bonus = float(data.get("affinity_bonus", 1.5))
	d.flavor_text = str(data.get("flavor_text", ""))
	return d
