class_name Globals

enum Faction {
	PIRATES,
	CLERICS,
	DRUIDS,
	ARCHERS,
	MYCOLINGS,
	ROBOTS,
}

const faction_troops: Array[Texture2D] = [
	preload("res://game/map/hex/troop/pirate.png"),
	preload("res://game/map/hex/troop/cleric.png"),
	preload("res://game/map/hex/troop/pirate.png"),
	preload("res://game/map/hex/troop/pirate.png"),
	preload("res://game/map/hex/troop/mycoling.png"),
	preload("res://game/map/hex/troop/pirate.png"),
]
