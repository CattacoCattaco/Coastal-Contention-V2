class_name PlayerBar
extends PanelContainer

signal player_added(faction: FactionData)
signal setup_complete

@export var names_holder: HBoxContainer
@export var victory_screen: ColorRect
@export var victory_label: Label

@export var starting_players: Array[FactionData]
@export var label_settings: LabelSettings
@export var outline_shader: Shader

var current_turn: int = -1

var players: Array[FactionData]
var player_names: Dictionary[FactionData, ColorRect] = {}
var player_name_buttons: Dictionary[FactionData, Button] = {}


func _ready() -> void:
	setup_player_bar()


func reset_player_bar() -> void:
	for faction in players:
		player_names[faction].queue_free()
	
	player_names = {}
	player_name_buttons = {}
	current_turn = -1


func setup_player_bar() -> void:
	players = starting_players
	
	for player: FactionData in players:
		var name_rect := ColorRect.new()
		names_holder.add_child(name_rect)
		player_names[player] = name_rect
		
		name_rect.color = player.color
		
		var name_label := Label.new()
		name_rect.add_child(name_label)
		
		name_label.label_settings = label_settings
		name_label.text = player.name
		name_label.size = Vector2(0, 0)
		
		await RenderingServer.frame_post_draw
		
		name_rect.custom_minimum_size = name_label.size + Vector2(2, 4)
		name_label.position = Vector2(2, 2)
		
		await RenderingServer.frame_post_draw
		
		var name_rect_material := ShaderMaterial.new()
		name_rect_material.shader = outline_shader
		name_rect_material.set_shader_parameter(
				"size_pixels", name_rect.size)
		name_rect_material.set_shader_parameter(
				"override_opaque_color", name_rect.color)
		name_rect_material.set_shader_parameter(
				"use_override_opaque_color", true)
		name_rect_material.set_shader_parameter(
				"outline_color", Color.TRANSPARENT)
		
		name_rect.material = name_rect_material
		
		var name_button := Button.new()
		name_rect.add_child(name_button)
		player_name_buttons[player] = name_button
		
		name_button.set_anchors_preset(Control.PRESET_FULL_RECT, true)
		name_button.self_modulate = Color.TRANSPARENT
		
		player_added.emit(player)
	
	next()
	setup_complete.emit()


func remove_player(faction: FactionData) -> void:
	_remove_player_no_loss_check(faction)
	
	if players.size() == 1:
		do_victory(players[0])


func remove_players(factions: Array[FactionData]) -> void:
	for faction: FactionData in factions:
		_remove_player_no_loss_check(faction)
	
	if players.size() == 1:
		do_victory(players[0])
	else:
		do_draw(factions)


# Don't call directly, just meant for use in remove_player and remove_players
func _remove_player_no_loss_check(faction: FactionData) -> void:
	if players[current_turn] == faction:
		next()
	elif players.find(faction) < current_turn:
		current_turn -= 1
	
	player_names[faction].queue_free()
	players.erase(faction)
	player_names.erase(faction)
	player_name_buttons.erase(faction)


func next() -> void:
	if current_turn != -1:
		highlight_player(get_current_player(), Color.TRANSPARENT)
	
	current_turn += 1
	if current_turn == players.size():
		current_turn = 0
	
	highlight_player(get_current_player(), Color("#e8c170"))


func highlight_player(player: FactionData, color: Color) -> void:
	player_names[player].material.set_shader_parameter("outline_color", color)


func get_current_player() -> FactionData:
	return players[current_turn]


func do_draw(factions: Array[FactionData]) -> void:
	victory_screen.show()
	
	var faction_names: Array[String] = [
		factions[0].name
	]
	for i: int in range(1, factions.size()):
		faction_names.append(factions[i].name.to_lower())
	
	if factions.size() == 2:
		victory_label.text = "%s and %s drew." % faction_names
	else:
		victory_label.text = ""
		
		for i: int in range(factions.size() - 1):
			victory_label.text += faction_names[i] + ", "
		
		victory_label.text += "and %s drew." % faction_names[-1]


func do_victory(faction: FactionData) -> void:
	victory_screen.show()
	
	victory_label.text = "%s won!" % faction.name
