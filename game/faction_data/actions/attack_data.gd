class_name AttackData
extends ActionData


func _init(p_outline_color := Color(), p_stage_count: int = 2,
		p_action_name: String = "Attack") -> void:
	super(p_outline_color, p_stage_count, p_action_name)


func _get_stage_input(stage: int) -> StageInput:
	match stage:
		1:
			return StageInput.TERRITORY_SELECT
		2:
			return StageInput.PLAYER_SELECT
	
	return StageInput.ERROR


func _get_stage_instruction(stage: int) -> String:
	match stage:
		1:
			return "Choose territory to attack in"
		2:
			return "Choose player to attack"
	
	return ""


func _get_selectable_territories(map: Map, player_bar: PlayerBar, stage: int,
		_selected_territories: Array[Territory]) -> Array[Territory]:
	var territories: Array[Territory] = []
	
	if stage == 1:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if territory.troop_hexes.size() < 2:
					continue
				if player_bar.get_current_player() not in territory.troop_hexes:
					continue
				
				territories.append(territory)
	
	return territories


func _get_selectable_players(player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[Faction]:
	var factions: Array[Faction] = []
	
	if stage == 2:
		for faction: Faction in player_bar.players:
			if faction not in selected_territories[0].troop_hexes:
				continue
			if faction == player_bar.get_current_player():
				continue
			
			factions.append(faction)
	
	return factions


func _get_action_menu(_stage: int) -> ActionMenu:
	return ActionMenu.ERROR


func _do_action(selected_territories: Array[Territory],
		selected_players: Array[Faction], map: Map, _troop_count_box: SpinBox,
		player_bar: PlayerBar) -> void:
	selected_territories[0].remove_troops(1, player_bar.get_current_player())
	selected_territories[0].remove_troops(2, selected_players[0])
	
	var attacked_lost: bool = true
	var attacker_lost: bool = true
	for continent_territories: Array in map.continents:
		for territory: Territory in continent_territories:
			if selected_players[0] in territory.troop_hexes:
				attacked_lost = false
			if player_bar.get_current_player() in territory.troop_hexes:
				attacker_lost = false
			
			if not (attacked_lost or attacker_lost): break
		
		if not (attacked_lost or attacker_lost): break
	
	if attacked_lost and attacker_lost:
		player_bar.remove_players([
			selected_players[0],
			player_bar.get_current_player()
		])
	elif attacked_lost:
		player_bar.remove_player(selected_players[0])
	elif attacker_lost:
		player_bar.remove_player(player_bar.get_current_player())
