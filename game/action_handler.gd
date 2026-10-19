class_name ActionHandler
extends VBoxContainer

enum Action {
	MOVE_PART_ONE,
	MOVE_PART_TWO,
	MOVE_PART_THREE,
	ATTACK_PART_ONE,
	ATTACK_PART_TWO,
	NONE,
}

const Faction = Globals.Faction

@export var player_bar: PlayerBar
@export var instruction_label: Label
@export var move_button: Button
@export var attack_button: Button
@export var next_button: Button
@export var cancel_button: Button
@export var troop_count_selection_panel: PanelContainer
@export var troop_count_box: SpinBox
@export var finish_move_button: Button
@export var map: Map
@export var victory_screen: ColorRect
@export var victory_label: Label
@export var new_game_button: Button

var selected_territories: Array[Territory] = []
var current_action: Action = Action.NONE
var actions_left: int = 3


func _ready() -> void:
	troop_count_selection_panel.hide()
	
	player_bar.player_added.connect(_player_name_added)
	map.territory_added.connect(_territory_added)
	
	move_button.pressed.connect(_start_move)
	attack_button.pressed.connect(_start_attack)
	next_button.pressed.connect(_next_turn)
	cancel_button.pressed.connect(_cancel_action)
	finish_move_button.pressed.connect(_finish_move)
	new_game_button.pressed.connect(_new_turn)


func _player_name_added(faction: Faction) -> void:
	var player_button: Button = player_bar.player_name_buttons[faction]
	player_button.pressed.connect(_player_selected.bind(faction))


func _territory_added(territory: Territory) -> void:
	territory.pressed.connect(_territory_pressed.bind(territory))


func _territory_pressed(territory: Territory) -> void:
	match current_action:
		Action.MOVE_PART_ONE:
			if player_bar.get_current_player() not in territory.troop_hexes:
				return
			
			selected_territories.append(territory)
			current_action = Action.MOVE_PART_TWO
			instruction_label.text = "Choose a territory to move to"
		Action.MOVE_PART_TWO:
			if territory not in selected_territories[0].border_territories:
				return
			
			selected_territories.append(territory)
			current_action = Action.MOVE_PART_THREE
			instruction_label.text = "Choose how many troops to move"
			
			var troop_hexes: Dictionary[Faction, Hex]
			troop_hexes = selected_territories[0].troop_hexes
			var troop_hex: Hex = troop_hexes[player_bar.get_current_player()]
			
			troop_count_selection_panel.show()
			troop_count_box.value = 1
			troop_count_box.max_value = troop_hex.troop_count
		Action.ATTACK_PART_ONE:
			if player_bar.get_current_player() not in territory.troop_hexes:
				return
			if territory.troop_hexes.size() == 1:
				return
			
			selected_territories.append(territory)
			current_action = Action.ATTACK_PART_TWO
			instruction_label.text = "Choose a player to attack"


func _player_selected(faction: Faction) -> void:
	match current_action:
		Action.ATTACK_PART_TWO:
			if faction not in selected_territories[0].troop_hexes:
				return
			if faction == player_bar.get_current_player():
				return
			finish_attack(faction)


func _start_move() -> void:
	_cancel_action()
	cancel_button.show()
	
	instruction_label.text = "Choose a territory to move from"
	
	current_action = Action.MOVE_PART_ONE


func _start_attack() -> void:
	_cancel_action()
	cancel_button.show()
	
	instruction_label.text = "Choose a territory to attack in"
	
	current_action = Action.ATTACK_PART_ONE


func _finish_move() -> void:
	var current_player: Faction = player_bar.get_current_player()
	var move_count: int = roundi(troop_count_box.value)
	selected_territories[0].remove_troops(move_count, current_player)
	selected_territories[1].add_troops(move_count, current_player)
	
	actions_left -= 1
	if actions_left == 0:
		_next_turn()
	
	_cancel_action()


func finish_attack(faction_attacked: Faction) -> void:
	selected_territories[0].remove_troops(1, player_bar.get_current_player())
	selected_territories[0].remove_troops(2, faction_attacked)
	
	actions_left -= 1
	if actions_left == 0:
		_next_turn()
	
	_cancel_action()
	
	var attacked_lost: bool = true
	var attacker_lost: bool = true
	for continent_territories: Array in map.continents:
		for territory: Territory in continent_territories:
			if faction_attacked in territory.troop_hexes:
				attacked_lost = false
			if player_bar.get_current_player() in territory.troop_hexes:
				attacker_lost = false
			
			if not (attacked_lost or attacker_lost): break
		
		if not (attacked_lost or attacker_lost): break
	
	if attacked_lost and attacker_lost:
		player_bar.remove_player(faction_attacked)
		player_bar.remove_player(player_bar.get_current_player())
		
		if player_bar.players.size() == 0:
			do_draw([faction_attacked, player_bar.get_current_player()])
	elif attacked_lost:
		player_bar.remove_player(faction_attacked)
		
		if player_bar.players.size() == 1:
			do_victory(player_bar.get_current_player())
	elif attacker_lost:
		player_bar.remove_player(player_bar.get_current_player())
		
		if player_bar.players.size() == 1:
			do_victory(faction_attacked)


func _next_turn() -> void:
	player_bar.next()
	
	_new_turn()


func _new_turn() -> void:
	actions_left = 3
	
	_cancel_action()


func _cancel_action() -> void:
	selected_territories = []
	current_action = Action.NONE
	instruction_label.text = "Choose an action. (%d/3 actions left)"
	instruction_label.text %= actions_left
	troop_count_selection_panel.hide()
	cancel_button.hide()


func do_draw(factions: Array[Faction]) -> void:
	victory_screen.show()
	
	var faction_names: Array[String] = [
		Globals.faction_names[factions[0]]
	]
	for i: int in range(1, factions.size()):
		faction_names.append(Globals.faction_names[factions[i]].to_lower())
	
	if factions.size() == 2:
		victory_label.text = "%s and %s drew." % faction_names
	else:
		victory_label.text = ""
		
		for i: int in range(factions.size() - 1):
			victory_label.text += faction_names[i] + ", "
		
		victory_label.text += "and %s drew." % faction_names[-1]


func do_victory(faction: Faction) -> void:
	victory_screen.show()
	
	victory_label.text = "%s won!" % Globals.faction_names[faction]
