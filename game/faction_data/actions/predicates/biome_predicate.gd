class_name BiomePredicate
extends Predicate

const Biome = Globals.Biome

@export var biome: Biome


func _init(p_biome: Biome = Biome.PLAINS) -> void:
	biome = p_biome


func _fits(territory: Territory, _player_bar: PlayerBar) -> bool:
	return territory.territory.biome == biome
