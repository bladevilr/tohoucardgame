extends Resource
class_name DishData

## Unique identifier (e.g. "peking_duck")
@export var id: String = ""
## Display name (e.g. "北京烤鸭")
@export var name: String = ""
## English name
@export var name_en: String = ""
## Item size: 1=Small, 2=Medium, 3=Large
@export_range(1, 3) var size: int = 1
## Cooldown in seconds
@export var cooldown: float = 3.0
## Cuisine category
@export var cuisine: String = ""
## Tags for trigger matching
@export var tags: Array[String] = []
## Tier: 0=Bronze, 1=Silver, 2=Gold, 3=Diamond
@export_range(0, 3) var tier: int = 0
## Shop cost
@export var cost: int = 2
## Base stats
@export var base_stats: Dictionary = {"flavor": 0, "presentation": 0, "technique": 0, "aroma": 0}
## Effects executed when this item activates (serves)
@export var on_activate: Array[Dictionary] = []
## Trigger conditions and effects
@export var triggers: Array[Dictionary] = []
## Suggested pairing item IDs
@export var pairings: Array[String] = []

func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "name_en": name_en,
		"size": size, "cooldown": cooldown, "cuisine": cuisine,
		"tags": Array(tags), "tier": tier, "cost": cost,
		"base_stats": base_stats.duplicate(),
		"on_activate": on_activate.duplicate(true),
		"triggers": triggers.duplicate(true),
		"pairings": Array(pairings),
	}

static func from_dict(data: Dictionary) -> DishData:
	var d = DishData.new()
	d.id = data.get("id", "")
	d.name = data.get("name", "")
	d.name_en = data.get("name_en", "")
	d.size = int(data.get("size", 1))
	d.cooldown = float(data.get("cooldown", 3.0))
	d.cuisine = str(data.get("cuisine", ""))
	for t in data.get("tags", []):
		d.tags.append(str(t))
	d.tier = int(data.get("tier", 0))
	d.cost = int(data.get("cost", 2))
	d.base_stats = data.get("base_stats", {}).duplicate()
	d.on_activate = data.get("on_activate", []).duplicate(true)
	d.triggers = data.get("triggers", []).duplicate(true)
	for p in data.get("pairings", []):
		d.pairings.append(str(p))
	return d
