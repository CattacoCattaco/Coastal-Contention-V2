class_name MoveData
extends ActionData


func _init(p_outline_color := Color(), p_stage_count: int = 3,
		p_action_name: String = "Move") -> void:
	super(p_outline_color, p_stage_count, p_action_name)


func _get_stage_input(stage: int) -> StageInput:
	match stage:
		1, 2:
			return StageInput.TERRITORY_SELECT
		3:
			return StageInput.OPEN_MENU
	
	return StageInput.ERROR


func _get_stage_instruction(stage: int) -> String:
	match stage:
		1:
			return "Choose territory to move from"
		2:
			return "Choose territory to move to"
		3:
			return "Choose number of troops to move"
	
	return ""


func _get_selectable_territories(map: Map, player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[Territory]:
	var territories: Array[Territory] = []
	
	match stage:
		1:
			var current_player: Faction = player_bar.get_current_player()
			for continent: Array in map.continents:
				for territory: Territory in continent:
					if current_player not in territory.troop_hexes:
						continue
					
					territories.append(territory)
		2:
			var neighbors: Array[Territory]
			neighbors = selected_territories[0].border_territories
			
			for territory: Territory in neighbors:
				territories.append(territory)
	
	return territories


func _get_selectable_players(_player_bar: PlayerBar, _stage: int,
		_selected_territories: Array[Territory]) -> Array[Faction]:
	return []


func _get_action_menu(stage: int) -> ActionMenu:
	if stage == 3:
		return ActionMenu.MOVE_MENU
	
	return ActionMenu.ERROR


func _do_action(selected_territories: Array[Territory],
		_selected_players: Array[Faction], _map: Map, troop_count_box: SpinBox,
		player_bar: PlayerBar) -> void:
	var current_player: Faction = player_bar.get_current_player()
	var move_count: int = roundi(troop_count_box.value)
	selected_territories[0].remove_troops(move_count, current_player)
	selected_territories[1].add_troops(move_count, current_player)
