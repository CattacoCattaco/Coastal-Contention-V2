class_name NeighborPredicate
extends Predicate

@export var predicates: Array[Predicate]


func _init(p_predicates: Array[Predicate] = []) -> void:
	predicates = p_predicates


func _fits(territory: Territory, player_bar: PlayerBar) -> bool:
	for neighbor: Territory in territory.border_territories:
		if Predicate.fits_list(predicates, neighbor, player_bar):
			return true
	
	return false
