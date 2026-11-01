@tool
class_name SporeActionData
extends ActionData

const SPORE: Texture2D = preload("res://game/map/hex/token/spore.png")
const SPORE_USED: Texture2D = preload("res://game/map/hex/token/spore_used.png")

const EXTERNAL_SPORE_SELECTION: int = -1

## Index of territory to remove from (0 = first selected territory,
## 1 = second, etc.)
@export var territory_index: int:
	set(value):
		territory_index = value
		
		if not base_action:
			return
		
		if territory_index == EXTERNAL_SPORE_SELECTION:
			stage_count = base_action.stage_count + 1
		else:
			stage_count = base_action.stage_count

@export var remove_spore: bool

@export var base_action: ActionData:
	set(value):
		base_action = value
		
		if not value:
			return
		
		if territory_index == EXTERNAL_SPORE_SELECTION:
			stage_count = base_action.stage_count + 1
		else:
			stage_count = base_action.stage_count

@export_tool_button("Update stages") var update_stages := func () -> void:
	if territory_index == EXTERNAL_SPORE_SELECTION:
		stage_count = base_action.stage_count + 1
	else:
		stage_count = base_action.stage_count
	
	ResourceSaver.save(self, resource_path)


func _init(p_outline_color := Color(), p_stage_count: int = 3,
		p_action_name: String = "Move", p_territory_index: int = 0,
		p_remove_spore: bool = false, p_base_action: ActionData = null) -> void:
	territory_index = p_territory_index
	remove_spore = p_remove_spore
	base_action = p_base_action
	
	super(p_outline_color, p_stage_count, p_action_name)


func _get_stage_input(stage: int) -> StageInput:
	if stage <= base_action.stage_count:
		return base_action._get_stage_input(stage)
	elif territory_index == EXTERNAL_SPORE_SELECTION:
		return StageInput.TERRITORY_SELECT
	else:
		return StageInput.ERROR


func _get_stage_instruction(stage: int) -> String:
	if stage <= base_action.stage_count:
		return base_action._get_stage_instruction(stage)
	elif territory_index == EXTERNAL_SPORE_SELECTION:
		return "Choose spores to use"
	else:
		return ""


func _get_selectable_territories(map: Map, player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[Territory]:
	if stage <= base_action.stage_count:
		return base_action._get_selectable_territories(map, player_bar, stage,
				selected_territories)
	elif territory_index == EXTERNAL_SPORE_SELECTION:
		var selectable_territories: Array[Territory] = []
		
		for neighbor: Territory in selected_territories[0].border_territories:
			if neighbor.has_token(SPORE, player_bar.get_current_player()):
				selectable_territories.append(neighbor)
		
		return selectable_territories
	else:
		return []
	


func _get_selectable_players(player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[FactionData]:
	return base_action._get_selectable_players(player_bar, stage,
			selected_territories)


func _get_action_menu(stage: int) -> ActionMenu:
	return base_action._get_action_menu(stage)


func _do_action(selected_territories: Array[Territory],
		selected_players: Array[FactionData], map: Map,
		troop_count_box: SpinBox, player_bar: PlayerBar,
		attack_screen: AttackScreen, cleric_faith_panel: ClericFaithPanel
		) -> void:
	var player: FactionData = player_bar.get_current_player()
	var spore_territory: Territory = selected_territories[territory_index]
	
	if remove_spore:
		spore_territory.remove_token(SPORE, player)
	else:
		spore_territory.replace_token(SPORE, SPORE_USED, player)
	
	if territory_index == EXTERNAL_SPORE_SELECTION:
		selected_territories.pop_back()
	
	base_action._do_action(selected_territories, selected_players, map,
			troop_count_box, player_bar, attack_screen, cleric_faith_panel)
