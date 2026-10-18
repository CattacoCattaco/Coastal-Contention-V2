class_name PlayerBar
extends PanelContainer

const Faction = Globals.Faction

@export var names_holder: HBoxContainer

@export var players: Array[Faction]
@export var label_settings: LabelSettings

var player_names: Dictionary[Faction, ColorRect] = {}
var player_name_buttons: Dictionary[Faction, Button] = {}


func _ready() -> void:
	for player: Faction in players:
		var name_rect := ColorRect.new()
		names_holder.add_child(name_rect)
		player_names[player] = name_rect
		
		name_rect.color = Globals.faction_colors[player]
		
		var name_label := Label.new()
		name_rect.add_child(name_label)
		
		name_label.label_settings = label_settings
		name_label.text = Globals.faction_names[player]
		name_label.size = Vector2(0, 0)
		
		await RenderingServer.frame_post_draw
		
		name_rect.custom_minimum_size = name_label.size + Vector2(2, 4)
		name_label.position = Vector2(2, 2)
		
		var name_button := Button.new()
		name_rect.add_child(name_button)
		player_name_buttons[player] = name_button
		
		name_button.set_anchors_preset(Control.PRESET_FULL_RECT, true)
		name_button.self_modulate = Color.TRANSPARENT
