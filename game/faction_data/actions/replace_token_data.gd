@tool
class_name ReplaceTokenData
extends ActionData

const REPLACE_ANY: int = -1
const REPLACE_ALL: int = -2

## Number of territories to recruit to
## [br]-1 = any number (not implemented)
## [br]-2 = all
@export var territory_count: int = 1:
	set(value):
		territory_count = value
		stage_count = value
		
		if value == REPLACE_ANY:
			stage_count = -1
		if value == REPLACE_ALL:
			stage_count = 0

@export var old_token_sprite: Texture2D
@export var new_token_sprite: Texture2D
@export var message: String

@export var predicates: Array[Predicate]


func _init(p_outline_color := Color(), p_stage_count: int = 1,
		p_action_name: String = "Recruit", p_territory_count: int = 1,
		p_old_token_sprite: Texture2D = null,
		p_new_token_sprite: Texture2D = null, p_message: String = "",
		p_predicates: Array[Predicate] = []) -> void:
	territory_count = p_territory_count
	old_token_sprite = p_old_token_sprite
	new_token_sprite = p_new_token_sprite
	message = p_message
	predicates = p_predicates
	
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
	var player: FactionData = player_bar.get_current_player()
	var territories: Array[Territory] = []
	
	if stage <= territory_count or territory_count == -1:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if territory in selected_territories:
					continue
				if not Predicate.fits_list(predicates, territory, player_bar):
					continue
				if not territory.has_token(old_token_sprite, player):
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
		_attack_screen: AttackScreen, _cleric_faith_panel: ClericFaithPanel
		) -> void:
	var player: FactionData = player_bar.get_current_player()
	
	if territory_count == REPLACE_ALL:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if not Predicate.fits_list(predicates, territory, player_bar):
					continue
				if not territory.has_token(old_token_sprite, player):
					continue
				
				selected_territories.append(territory)
	
	for territory: Territory in selected_territories:
		territory.replace_token(old_token_sprite, new_token_sprite,
				player_bar.get_current_player())
