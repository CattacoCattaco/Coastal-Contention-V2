class_name ControlPredicate
extends Predicate


func _fits(territory: Territory, player_bar: PlayerBar) -> bool:
	return territory.controller == player_bar.get_current_player()
