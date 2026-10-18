class_name PlayerBar
extends PanelContainer

const Faction = Globals.Faction

@export var names_holder: HBoxContainer

@export var players: Array[Faction]
@export var label_settings: LabelSettings

var player_names: Dictionary[Faction, ColorRect] = {}


func _ready() -> void:
	for player: Faction in players:
		var name_rect := ColorRect.new()
		names_holder.add_child(name_rect)
		
		name_rect.color = Globals.faction_colors[player]
		
		var name_label := Label.new()
		name_rect.add_child(name_label)
		
		name_label.size = Vector2(0, 0)
		name_label.label_settings = label_settings
		name_label.text = Globals.faction_names[player]
		
		await RenderingServer.frame_post_draw
		
		name_rect.custom_minimum_size = name_label.size + Vector2(2, 4)
		name_label.position = Vector2(2, 2)
