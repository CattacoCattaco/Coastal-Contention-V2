class_name ActionHandler
extends VBoxContainer

signal action_completed

const StageInput = ActionData.StageInput
const ActionMenu = ActionData.ActionMenu

@export var map: Map
@export var player_bar: PlayerBar
@export var instruction_label: Label
@export var next_button: Button
@export var cancel_button: Button
@export var troop_count_selection_panel: PanelContainer
@export var troop_count_box: SpinBox
@export var finish_move_button: Button
@export var attack_screen: AttackScreen
@export var new_game_button: Button

@export var actions: Array[ActionData]
@export var button_theme: Theme

var highlighted_players: Array[FactionData] = []
var selected_players: Array[FactionData] = []
var highlighted_territories: Array[Territory] = []
var selected_territories: Array[Territory] = []
var current_action: ActionData = null
var current_stage: int = 1
var actions_left: int = 3


func _ready() -> void:
	troop_count_selection_panel.hide()
	attack_screen.hide()
	
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
	finish_move_button.pressed.connect(_finish_move_pressed)
	new_game_button.pressed.connect(_setup)
	
	_setup()


func _setup() -> void:
	await  player_bar.setup_complete
	
	for faction: FactionData in player_bar.players:
		for action: ActionData in faction.setup_actions:
			_start_action(action)
			
			await action_completed
		
		_next_turn()
	
	_new_turn()


func _player_name_added(faction: FactionData) -> void:
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
	
	start_stage()


func _player_selected(faction: FactionData) -> void:
	if faction not in highlighted_players:
		return
	
	unhighlight_players()
	highlighted_players = []
	
	selected_players.append(faction)
	current_stage += 1
	
	start_stage()


func _finish_move_pressed() -> void:
	current_stage += 1
	
	start_stage()


func _start_action(action: ActionData) -> void:
	_cancel_action()
	cancel_button.show()
	
	current_action = action
	
	start_stage()


func start_stage() -> void:
	if current_stage > current_action.stage_count:
		var old_current_player: FactionData = player_bar.get_current_player()
		
		# THIS DOES NOT REMOVE THE NEED FOR THE BELOW await!!!
		# _do_action() may or may not be asyncronous
		@warning_ignore("redundant_await")
		await current_action._do_action(selected_territories, selected_players,
				map, troop_count_box, player_bar, attack_screen)
		
		var new_current_player: FactionData = player_bar.get_current_player()
		
		actions_left -= 1
		if actions_left == 0 and new_current_player == old_current_player:
			_next_turn()
		else:
			_cancel_action()
		
		# Important for awaiting action_completed after starting a zero stage
		# action (Like Mycoling recruit). DO NOT REMOVE!!!
		await RenderingServer.frame_post_draw
		
		action_completed.emit()
		
		return
	
	var stage_input: StageInput = current_action._get_stage_input(current_stage)
	
	instruction_label.text = current_action._get_stage_instruction(
			current_stage)
	
	match stage_input:
		StageInput.TERRITORY_SELECT:
			var selectable_territories: Array[Territory]
			selectable_territories = current_action._get_selectable_territories(
					map, player_bar, current_stage, selected_territories)
			
			for selectable_territory: Territory in selectable_territories:
				highlighted_territories.append(selectable_territory)
			
			highlight_territories()
		StageInput.PLAYER_SELECT:
			var selectable_players: Array[FactionData]
			selectable_players = current_action._get_selectable_players(
					player_bar, current_stage, selected_territories)
			
			for selectable_player: FactionData in selectable_players:
				highlighted_players.append(selectable_player)
			
			highlight_players()
		StageInput.OPEN_MENU:
			match current_action._get_action_menu(current_stage):
				ActionMenu.MOVE_MENU:
					troop_count_selection_panel.show()
					
					var player: FactionData = player_bar.get_current_player()
					var troop_hex: Hex
					troop_hex = selected_territories[0].troop_hexes[player]
					
					troop_count_box.value = 1
					troop_count_box.min_value = 1
					troop_count_box.max_value = troop_hex.troop_count


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
	selected_players = []
	highlighted_territories = []
	selected_territories = []
	
	troop_count_selection_panel.hide()
	attack_screen.hide()
	cancel_button.hide()


func highlight_players() -> void:
	for player: FactionData in highlighted_players:
		var override_colors: Dictionary[Color, Color]
		override_colors = player.name_highlight_overrides
		
		var highlight_color: Color = current_action.outline_color
		if highlight_color in override_colors:
			highlight_color = override_colors[highlight_color]
		
		player_bar.highlight_player(player, highlight_color)


func unhighlight_players() -> void:
	for player: FactionData in highlighted_players:
		player_bar.highlight_player(player, Color.TRANSPARENT)


func highlight_territories() -> void:
	for territory: Territory in highlighted_territories:
		territory.set_outline_color(current_action.outline_color)


func unhighlight_territories() -> void:
	for territory: Territory in highlighted_territories:
		territory.set_outline_color(Color.TRANSPARENT)
