@tool
class_name CreateTokenData
extends ActionData

const CREATE_ANY: int = -1
const CREATE_ALL: int = -2

## Number of territories to recruit to
## [br]-1 = any number (not implemented)
## [br]-2 = all
@export var territory_count: int = 1:
	set(value):
		territory_count = value
		stage_count = value
		
		if value == CREATE_ANY:
			stage_count = -1
		if value == CREATE_ALL:
			stage_count = 0

@export var token_sprite: Texture2D
@export var message: String

@export var predicates: Array[Predicate]

@export var incrament_faith: bool


func _init(p_outline_color := Color(), p_stage_count: int = 1,
		p_action_name: String = "Recruit", p_territory_count: int = 1,
		p_token_sprite: Texture2D = null, p_message: String = "",
		p_predicates: Array[Predicate] = [], p_incrament_faith: bool = false
		) -> void:
	territory_count = p_territory_count
	token_sprite = p_token_sprite
	message = p_message
	predicates = p_predicates
	incrament_faith = p_incrament_faith
	
	super(p_outline_color, p_stage_count, p_action_name)


func _get_stage_input(stage: int) -> StageInput:
	if stage <= territory_count or territory_count == -1:
			return StageInput.TERRITORY_SELECT
	
	return StageInput.ERROR


func _get_stage_instruction(stage: int) -> String:
	if stage <= territory_count or territory_count == -1:
		return message
	
	return ""


func _get_selectable_territories(map: Map, player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[Territory]:
	var territories: Array[Territory] = []
	
	if stage <= territory_count or territory_count == -1:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if territory in selected_territories:
					continue
				if not Predicate.fits_list(predicates, territory, player_bar):
					continue
				
				territories.append(territory)
	
	return territories


func _get_selectable_players(_player_bar: PlayerBar, _stage: int,
		_selected_territories: Array[Territory]) -> Array[FactionData]:
	return []


func _get_action_menu(_stage: int) -> ActionMenu:
	return ActionMenu.ERROR


func _do_action(selected_territories: Array[Territory],
		_selected_players: Array[FactionData], map: Map,
		_token_count_box: SpinBox, player_bar: PlayerBar,
		_attack_screen: AttackScreen, cleric_faith_panel: ClericFaithPanel
		) -> void:
	if territory_count == CREATE_ALL:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if not Predicate.fits_list(predicates, territory, player_bar):
					continue
				
				selected_territories.append(territory)
	
	for territory: Territory in selected_territories:
		territory.add_token(token_sprite, player_bar.get_current_player())
		if incrament_faith:
			cleric_faith_panel.add_faith(territory.territory.biome)
