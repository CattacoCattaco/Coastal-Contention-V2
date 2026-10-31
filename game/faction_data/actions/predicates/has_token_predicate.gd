class_name HasTokenPredicate
extends Predicate

@export var sprite: Texture2D


func _init(p_sprite: Texture2D = null) -> void:
	sprite = p_sprite


func _fits(territory: Territory, player_bar: PlayerBar) -> bool:
	var player: FactionData = player_bar.get_current_player()
	
	return territory.has_token(sprite, player)
