class_name MoveData
extends ActionData


func _init(p_outline_color := Color(), p_stage_count: int = 3) -> void:
	super(p_outline_color, p_stage_count)


func _get_stage_input(stage: int) -> StageInput:
	match stage:
		1, 2:
			return StageInput.TERRITORY_SELECT
		3:
			return StageInput.OPEN_MENU
	
	return StageInput.ERROR


func _get_selectable_territories(continents: Array[Array],
		stage: int, selected_territories: Array[Territory]) -> Array[Territory]:
	var territories: Array[Territory] = []
	
	match stage:
		1:
			for continent: Array in continents:
				for territory: Territory in continent:
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
