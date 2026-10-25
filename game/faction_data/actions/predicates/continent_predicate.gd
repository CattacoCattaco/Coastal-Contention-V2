class_name ContinentPredicate
extends Predicate

const Continent = Globals.Continent

@export var continent: Continent


func _init(p_continent: Continent = Continent.RED) -> void:
	continent = p_continent


func _fits(territory: Territory) -> bool:
	return territory.territory.continent == continent
