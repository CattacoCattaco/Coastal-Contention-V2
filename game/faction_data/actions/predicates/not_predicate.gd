class_name NotPredicate
extends Predicate

@export var predicate: Predicate


func _init(p_predicate: Predicate = null) -> void:
	predicate = p_predicate


func _fits(territory: Territory, player_bar: PlayerBar) -> bool:
	return not predicate._fits(territory, player_bar)
