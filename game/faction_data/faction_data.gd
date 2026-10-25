class_name FactionData
extends Resource

@export var name: String
@export var color: Color
@export var troop_sprite: Texture2D
@export var control_banners: Texture2D
@export var setup_actions: Array[ActionData]
@export var name_highlight_overrides: Dictionary[Color, Color]


func _init(p_name: String = "", p_color := Color(),
		p_troop_sprite: Texture2D = null, p_control_banners: Texture2D = null,
		p_setup_actions: Array[ActionData] = [],
		p_name_highlight_overrides: Dictionary[Color, Color] = {}) -> void:
	name = p_name
	color = p_color
	troop_sprite = p_troop_sprite
	control_banners = p_control_banners
	setup_actions = p_setup_actions
	name_highlight_overrides = p_name_highlight_overrides
