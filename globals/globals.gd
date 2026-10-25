class_name Globals

enum Continent {
	RED,
	GOLD,
	BROWN,
	GREEN,
	MAGENTA,
	SILVER,
}

enum Biome {
	PLAINS,
	MOUNTAINS,
	FOREST,
	SWAMP,
}

const FACTIONS: Array[FactionData] = [
	preload("res://game/faction_data/data/pirates.tres"),
	preload("res://game/faction_data/data/clerics.tres"),
	preload("res://game/faction_data/data/druids.tres"),
	preload("res://game/faction_data/data/archers.tres"),
	preload("res://game/faction_data/data/mycolings.tres"),
	preload("res://game/faction_data/data/robots.tres"),
]
