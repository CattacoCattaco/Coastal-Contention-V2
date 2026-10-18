class_name ActionHandler
extends VBoxContainer

enum Action {
	MOVE_PART_ONE,
	MOVE_PART_TWO,
	MOVE_PART_THREE,
	NONE,
}

const Faction = Globals.Faction

@export var map: Map
@export var instruction_label: Label
@export var move_button: Button
@export var troop_count_selection_panel: PanelContainer
@export var troop_count_box: SpinBox
@export var finish_move_button: Button

var selected_territories: Array[Territory] = []
var current_action: Action = Action.NONE


func _ready() -> void:
	instruction_label.hide()
	troop_count_selection_panel.hide()
	
	for continent_territories: Array in map.continents:
		for territory: Territory in continent_territories:
			territory.pressed.connect(_territory_pressed.bind(territory))
	
	map.territory_added.connect(_territory_added)
	
	move_button.pressed.connect(_start_move)
	finish_move_button.pressed.connect(_finish_move)


func _territory_added(territory: Territory) -> void:
	territory.pressed.connect(_territory_pressed.bind(territory))


func _territory_pressed(territory: Territory) -> void:
	match current_action:
		Action.MOVE_PART_ONE:
			print(territory.troop_hexes)
			if Faction.PIRATES in territory.troop_hexes:
				selected_territories.append(territory)
				current_action = Action.MOVE_PART_TWO
				instruction_label.text = "Choose a territory to move to"
		Action.MOVE_PART_TWO:
			if territory in selected_territories[0].border_territories:
				selected_territories.append(territory)
				current_action = Action.MOVE_PART_THREE
				instruction_label.text = "Choose how many troops to move"
				
				var troop_hexes: Dictionary[Faction, Hex]
				troop_hexes = selected_territories[0].troop_hexes
				var troop_hex: Hex = troop_hexes[Faction.PIRATES]
				
				troop_count_selection_panel.show()
				troop_count_box.value = 1
				troop_count_box.max_value = troop_hex.troop_count
		Action.MOVE_PART_THREE, Action.NONE:
			return


func _start_move() -> void:
	instruction_label.show()
	instruction_label.text = "Choose a territory to move from"
	
	current_action = Action.MOVE_PART_ONE


func _finish_move() -> void:
	var move_count: int = roundi(troop_count_box.value)
	selected_territories[0].remove_troops(move_count, Faction.PIRATES)
	selected_territories[1].add_troops(move_count, Faction.PIRATES)
	
	current_action = Action.NONE
	selected_territories = []
	
	troop_count_selection_panel.hide()
	instruction_label.hide()
