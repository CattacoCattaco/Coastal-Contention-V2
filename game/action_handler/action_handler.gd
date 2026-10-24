class_name ActionHandler
extends VBoxContainer

const Faction = Globals.Faction
const StageInput = ActionData.StageInput
const ActionMenu = ActionData.ActionMenu

@export var player_bar: PlayerBar
@export var instruction_label: Label
@export var next_button: Button
@export var cancel_button: Button
@export var troop_count_selection_panel: PanelContainer
@export var troop_count_box: SpinBox
@export var finish_move_button: Button
@export var map: Map
@export var victory_screen: ColorRect
@export var victory_label: Label
@export var new_game_button: Button

@export var actions: Array[ActionData]
@export var button_theme: Theme

var highlighted_players: Array[Faction] = []
var highlighted_territories: Array[Territory] = []
var selected_territories: Array[Territory] = []
var current_action: ActionData = null
var current_stage: int = 1
var actions_left: int = 3


func _ready() -> void:
	troop_count_selection_panel.hide()
	
	player_bar.player_added.connect(_player_name_added)
	map.territory_added.connect(_territory_added)
	
	for continent: Array in map.continents:
		for territory: Territory in continent:
			territory.pressed.connect(_territory_pressed.bind(territory))
	
	for action: ActionData in actions:
		var action_button := Button.new()
		add_child(action_button)
		
		action_button.theme = button_theme
		action_button.text = action.action_name
		action_button.pressed.connect(_start_action.bind(action))
	
	next_button.move_to_front()
	cancel_button.move_to_front()
	
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
	if territory not in highlighted_territories:
		return
	
	unhighlight_territories()
	highlighted_territories = []
	
	selected_territories.append(territory)
	current_stage += 1
	instruction_label.text = current_action._get_stage_instruction(current_stage)
	
	start_stage()


func _player_selected(faction: Faction) -> void:
	if faction not in highlighted_players:
		return
	
	finish_attack(faction)


func _start_action(action: ActionData) -> void:
	_cancel_action()
	cancel_button.show()
	
	instruction_label.text = action._get_stage_instruction(1)
	
	current_action = action
	
	start_stage()


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


func start_stage() -> void:
	var stage_input: StageInput = current_action._get_stage_input(current_stage)
	
	match stage_input:
		StageInput.TERRITORY_SELECT:
			var selectable_territories: Array[Territory]
			selectable_territories = current_action._get_selectable_territories(
					map, player_bar, current_stage, selected_territories)
			
			for selectable_territory: Territory in selectable_territories:
				highlighted_territories.append(selectable_territory)
			
			highlight_territories()
		StageInput.PLAYER_SELECT:
			var selectable_players: Array[Faction]
			selectable_players = current_action._get_selectable_players(
					player_bar, current_stage, selected_territories)
			
			for selectable_player: Faction in selectable_players:
				highlighted_players.append(selectable_player)
			
			highlight_players()
		StageInput.OPEN_MENU:
			match current_action._get_action_menu(current_stage):
				ActionMenu.MOVE_MENU:
					troop_count_selection_panel.show()


func _next_turn() -> void:
	_new_turn()
	
	player_bar.next()


func _new_turn() -> void:
	actions_left = 3
	
	_cancel_action()


func _cancel_action() -> void:
	current_action = null
	current_stage = 1
	
	instruction_label.text = "Choose an action. (%d/3 actions left)"
	instruction_label.text %= actions_left
	
	unhighlight_players()
	unhighlight_territories()
	
	highlighted_players = []
	highlighted_territories = []
	selected_territories = []
	
	troop_count_selection_panel.hide()
	cancel_button.hide()


func highlight_players() -> void:
	for player: Faction in highlighted_players:
		var override_colors: Dictionary
		override_colors = Globals.FACTION_BAR_OVERRIDE_COLORS[player]
		
		var highlight_color: Color = current_action.outline_color
		if highlight_color in override_colors:
			highlight_color = override_colors[highlight_color]
		
		player_bar.highlight_player(player, highlight_color)


func unhighlight_players() -> void:
	for player: Faction in highlighted_players:
		player_bar.highlight_player(player, Color.TRANSPARENT)


func highlight_territories() -> void:
	for territory: Territory in highlighted_territories:
		territory.set_outline_color(current_action.outline_color)


func unhighlight_territories() -> void:
	for territory: Territory in highlighted_territories:
		territory.set_outline_color(Color.TRANSPARENT)


func do_draw(factions: Array[Faction]) -> void:
	victory_screen.show()
	
	var faction_names: Array[String] = [
		Globals.FACTION_NAMES[factions[0]]
	]
	for i: int in range(1, factions.size()):
		faction_names.append(Globals.FACTION_NAMES[factions[i]].to_lower())
	
	if factions.size() == 2:
		victory_label.text = "%s and %s drew." % faction_names
	else:
		victory_label.text = ""
		
		for i: int in range(factions.size() - 1):
			victory_label.text += faction_names[i] + ", "
		
		victory_label.text += "and %s drew." % faction_names[-1]


func do_victory(faction: Faction) -> void:
	victory_screen.show()
	
	victory_label.text = "%s won!" % Globals.FACTION_NAMES[faction]
