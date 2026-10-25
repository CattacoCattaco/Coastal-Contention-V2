@tool
class_name CompoundData
extends ActionData

@export var actions: Array[ActionData]
@export_tool_button("Update steps") var update_steps := func () -> void:
	stage_count = 0
	for action: ActionData in actions: stage_count += action.stage_count
	ResourceSaver.save(self, resource_path)


func _init(p_outline_color := Color(), p_stage_count: int = 3,
		p_action_name: String = "") -> void:
	super(p_outline_color, p_stage_count, p_action_name)


func _get_stage_input(stage: int) -> StageInput:
	var action_stage: int = _get_stage_in_action(stage)
	return _get_action(stage)._get_stage_input(action_stage)


func _get_stage_instruction(stage: int) -> String:
	var action_stage: int = _get_stage_in_action(stage)
	return _get_action(stage)._get_stage_instruction(action_stage)


func _get_selectable_territories(map: Map, player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[Territory]:
	var current_stage: int = 0
	var current_selected_territory_index: int = 0
	
	for action: ActionData in actions:
		var p_selected_territories: Array[Territory] = []
		
		for i in range(action.stage_count):
			if current_stage == stage - 1:
				var action_stage: int = _get_stage_in_action(stage)
				return _get_action(stage)._get_selectable_territories(map,
						player_bar, action_stage, p_selected_territories)
			
			current_stage += 1
			
			var stage_input: StageInput = action._get_stage_input(i)
			match stage_input:
				StageInput.TERRITORY_SELECT:
					var selected_territory: Territory = selected_territories[
							current_selected_territory_index]
					current_selected_territory_index += 1
					p_selected_territories.append(selected_territory)
	
	return []


func _get_selectable_players(player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[FactionData]:
	var current_stage: int = 0
	var current_selected_territory_index: int = 0
	
	for action: ActionData in actions:
		var p_selected_territories: Array[Territory] = []
		
		for i in range(action.stage_count):
			if current_stage == stage - 1:
				var action_stage: int = _get_stage_in_action(stage)
				return _get_action(stage)._get_selectable_players(player_bar,
						action_stage, p_selected_territories)
			
			current_stage += 1
			
			var stage_input: StageInput = action._get_stage_input(i)
			match stage_input:
				StageInput.TERRITORY_SELECT:
					var selected_territory: Territory = selected_territories[
							current_selected_territory_index]
					current_selected_territory_index += 1
					p_selected_territories.append(selected_territory)
	
	return []


func _get_action_menu(stage: int) -> ActionMenu:
	var action_stage: int = _get_stage_in_action(stage)
	return _get_action(stage)._get_action_menu(action_stage)


func _do_action(selected_territories: Array[Territory],
		selected_players: Array[FactionData], map: Map,
		troop_count_box: SpinBox, player_bar: PlayerBar,
		attack_screen: AttackScreen) -> void:
	var current_selected_territory_index: int = 0
	var current_selected_player_index: int = 0
	
	for action: ActionData in actions:
		var p_selected_territories: Array[Territory] = []
		var p_selected_players: Array[FactionData] = []
		
		for i in range(action.stage_count):
			var stage_input: StageInput = action._get_stage_input(i)
			match stage_input:
				StageInput.TERRITORY_SELECT:
					var selected_territory: Territory = selected_territories[
							current_selected_territory_index]
					current_selected_territory_index += 1
					p_selected_territories.append(selected_territory)
				StageInput.PLAYER_SELECT:
					var selected_player: FactionData = selected_players[
							current_selected_player_index]
					current_selected_player_index += 1
					p_selected_players.append(selected_player)
		
		action._do_action(p_selected_territories, p_selected_players, map,
				troop_count_box, player_bar, attack_screen)


func _get_action(stage: int) -> ActionData:
	return actions[_get_action_index(stage)]


func _get_action_index(stage: int) -> int:
	var action_index: int = 0
	var accumulated_stage_count: int = 0
	
	for action: ActionData in actions:
		accumulated_stage_count += action.stage_count
		if accumulated_stage_count >= stage:
			return action_index
		action_index += 1
	
	return -1


func _get_stage_in_action(stage: int) -> int:
	var accumulated_stage_count: int = 0
	
	for action: ActionData in actions:
		accumulated_stage_count += action.stage_count
		if accumulated_stage_count >= stage:
			return stage - accumulated_stage_count + action.stage_count
	
	return -1
