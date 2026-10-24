@abstract
class_name ActionData
extends Resource

enum StageInput {
	TERRITORY_SELECT,
	PLAYER_SELECT,
	OPEN_MENU,
	ERROR,
}

enum ActionMenu {
	MOVE_MENU,
	ERROR,
}

const Faction = Globals.Faction

@export var outline_color: Color
@export var stage_count: int


func _init(p_outline_color := Color(), p_stage_count: int = 1) -> void:
	outline_color = p_outline_color
	stage_count = p_stage_count


@abstract func _get_stage_input(stage: int) -> StageInput

@abstract func _get_selectable_territories(map: Map, player_bar: PlayerBar,
		stage: int, selected_territories: Array[Territory]) -> Array[Territory]

@abstract func _get_selectable_players(player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[Faction]

@abstract func _get_action_menu(stage: int) -> ActionMenu
