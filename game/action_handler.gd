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

const ACTION_COLORS: Array[Color] = [
	Color("#73bed3"),
	Color("#73bed3"),
	Color("#73bed3"),
	Color("#cf573c"),
	Color("#a53030"),
	Color("#0000"),
]

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

var highlighted_territories: Array[Territory] = []
var selected_territories: Array[Territory] = []
var highlighted_players: Array[Faction] = []
var current_action: Action = Action.NONE
var actions_left: int = 3


func _ready() -> void:
	troop_count_selection_panel.hide()
	
	player_bar.player_added.connect(_player_name_added)
	map.territory_added.connect(_territory_added)
	
	for continent: Array in map.continents:
		for territory: Territory in continent:
			territory.pressed.connect(_territory_pressed.bind(territory))
	
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
			if territory not in highlighted_territories:
				return
			
			unhighlight_territories()
			highlighted_territories = []
			
			selected_territories.append(territory)
			current_action = Action.MOVE_PART_TWO
			instruction_label.text = "Choose a territory to move to"
			
			for neighbor: Territory in territory.border_territories:
				highlighted_territories.append(neighbor)
			
			highlight_territories()
		Action.MOVE_PART_TWO:
			if territory not in highlighted_territories:
				return
			
			unhighlight_territories()
			highlighted_territories = []
			
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
			if territory not in highlighted_territories:
				return
			
			unhighlight_territories()
			highlighted_territories = []
			
			selected_territories.append(territory)
			current_action = Action.ATTACK_PART_TWO
			instruction_label.text = "Choose a player to attack"
			
			for faction: Faction in player_bar.player_names:
				if (faction in selected_territories[0].troop_hexes
						and faction != player_bar.get_current_player()):
					highlighted_players.append(faction)
			
			highlight_players()


func _player_selected(faction: Faction) -> void:
	match current_action:
		Action.ATTACK_PART_TWO:
			if faction not in highlighted_players:
				return
			finish_attack(faction)


func _start_move() -> void:
	_cancel_action()
	cancel_button.show()
	
	instruction_label.text = "Choose a territory to move from"
	
	current_action = Action.MOVE_PART_ONE
	
	for continent: Array in map.continents:
		for territory: Territory in continent:
			if player_bar.get_current_player() in territory.troop_hexes:
				highlighted_territories.append(territory)
	
	highlight_territories()


func _start_attack() -> void:
	_cancel_action()
	cancel_button.show()
	
	instruction_label.text = "Choose a territory to attack in"
	
	current_action = Action.ATTACK_PART_ONE
	
	for continent: Array in map.continents:
		for territory: Territory in continent:
			if (player_bar.get_current_player() in territory.troop_hexes
					and territory.troop_hexes.size() > 1):
				highlighted_territories.append(territory)
	
	highlight_territories()


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
	current_action = Action.NONE
	
	instruction_label.text = "Choose an action. (%d/3 actions left)"
	instruction_label.text %= actions_left
	
	unhighlight_territories()
	unhighlight_players()
	
	highlighted_territories = []
	selected_territories = []
	
	troop_count_selection_panel.hide()
	cancel_button.hide()


func highlight_territories() -> void:
	for territory: Territory in highlighted_territories:
		territory.set_outline_color(ACTION_COLORS[current_action])


func unhighlight_territories() -> void:
	for territory: Territory in highlighted_territories:
		territory.set_outline_color(ACTION_COLORS[Action.NONE])


func highlight_players() -> void:
	for player: Faction in highlighted_players:
		player_bar.highlight_player(player, ACTION_COLORS[current_action])


func unhighlight_players() -> void:
	for player: Faction in highlighted_players:
		player_bar.highlight_player(player, ACTION_COLORS[Action.NONE])


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
