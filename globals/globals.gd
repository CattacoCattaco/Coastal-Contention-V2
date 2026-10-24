class_name Globals

enum Faction {
	PIRATES,
	CLERICS,
	DRUIDS,
	ARCHERS,
	MYCOLINGS,
	ROBOTS,
}

enum Continent {
	RED,
	GOLD,
	BROWN,
	GREEN,
	MAGENTA,
	SILVER,
}

const FACTION_NAMES: Array[String] = [
	"Pirates",
	"Clerics",
	"Druids",
	"Archers",
	"Mycolings",
	"Robots",
]

const FACTION_COLORS: Array[Color] = [
	Color("#a53030"),
	Color("#be772b"),
	Color("#ad7757"),
	Color("#75a743"),
	Color("#a23e8c"),
	Color("#577277"),
]

const FACTION_TROOPS: Array[Texture2D] = [
	preload("res://game/map/hex/troop/pirate.png"),
	preload("res://game/map/hex/troop/cleric.png"),
	preload("res://game/map/hex/troop/pirate.png"),
	preload("res://game/map/hex/troop/pirate.png"),
	preload("res://game/map/hex/troop/mycoling.png"),
	preload("res://game/map/hex/troop/pirate.png"),
]
