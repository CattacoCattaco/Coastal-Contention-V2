class_name PiecesPredicate
extends Predicate

@export var count_troops: bool
@export var count_tokens: bool
@export var min_pieces: int


func _init(p_count_troops: bool = true, p_count_tokens: bool = false,
		p_min_pieces: int = 1) -> void:
	count_troops = p_count_troops
	count_tokens = p_count_tokens
	min_pieces = p_min_pieces


func _fits(territory: Territory, player_bar: PlayerBar) -> bool:
	var player: FactionData = player_bar.get_current_player()
	var pieces: int = 0
	
	if count_troops and player in territory.troop_hexes:
		pieces += territory.troop_hexes[player].troop_count
	
	if count_tokens and player in territory.token_hexes:
		pieces += territory.token_hexes[player].size()
	
	return pieces >= min_pieces
