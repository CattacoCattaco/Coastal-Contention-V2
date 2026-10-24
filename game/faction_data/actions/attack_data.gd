class_name AttackData
extends ActionData


func _init(p_outline_color := Color(), p_stage_count: int = 2) -> void:
	super(p_outline_color, p_stage_count)


func _get_stage_input(stage: int) -> StageInput:
	match stage:
		1:
			return StageInput.TERRITORY_SELECT
		2:
			return StageInput.PLAYER_SELECT
	
	return StageInput.ERROR


func _get_selectable_territories(map: Map, player_bar: PlayerBar, stage: int,
		_selected_territories: Array[Territory]) -> Array[Territory]:
	var territories: Array[Territory] = []
	
	if stage == 1:
		for continent: Array in map.continents:
			for territory: Territory in continent:
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
