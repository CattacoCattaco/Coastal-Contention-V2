@tool
class_name RecruitData
extends ActionData

const RECRUIT_ANY: int = -1
const RECRUIT_ALL: int = -2

## Number of troops in each territory
@export var troop_count: int = 1
## Number of territories to recruit to
## [br]-1 = any number (not implemented)
## [br]-2 = all
@export var territory_count: int = 1:
	set(value):
		territory_count = value
		stage_count = value
		
		if value == RECRUIT_ANY:
			stage_count = -1
		if value == RECRUIT_ALL:
			stage_count = -2

@export var predicates: Array[Predicate]


func _init(p_outline_color := Color(), p_stage_count: int = 1,
		p_action_name: String = "Recruit", p_troop_count: int = 1,
		p_territory_count: int = 1, p_predicates: Array[Predicate] = []
		) -> void:
	troop_count = p_troop_count
	territory_count = p_territory_count
	predicates = p_predicates
	
	super(p_outline_color, p_stage_count, p_action_name)


func _get_stage_input(stage: int) -> StageInput:
	if stage <= territory_count or territory_count == -1:
			return StageInput.TERRITORY_SELECT
	
	return StageInput.ERROR


func _get_stage_instruction(stage: int) -> String:
	if stage <= territory_count or territory_count == -1:
		if territory_count == 1:
			return "Choose territory to recruit to"
		else:
			return "Choose territories to recruit to"
	
	return ""


func _get_selectable_territories(map: Map, _player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[Territory]:
	var territories: Array[Territory] = []
	
	if stage <= territory_count or territory_count == -1:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if territory in selected_territories:
					continue
				if not Predicate.fits_list(predicates, territory):
					continue
				
				territories.append(territory)
	
	return territories


func _get_selectable_players(_player_bar: PlayerBar, _stage: int,
		_selected_territories: Array[Territory]) -> Array[Faction]:
	return []


func _get_action_menu(_stage: int) -> ActionMenu:
	return ActionMenu.ERROR


func _do_action(selected_territories: Array[Territory],
		_selected_players: Array[Faction], map: Map, _troop_count_box: SpinBox,
		player_bar: PlayerBar) -> void:
	if territory_count == RECRUIT_ALL:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if territory in selected_territories:
					continue
				if not Predicate.fits_list(predicates, territory):
					continue
				
				selected_territories.append(territory)
	
	for territory: Territory in selected_territories:
		territory.add_troops(troop_count, player_bar.get_current_player())
