class_name FactionData
extends Resource

@export var name: String
@export var color: Color
@export var troop_sprite: Texture2D
@export var control_banners: Texture2D
@export var name_highlight_overrides: Dictionary[Color, Color]
@export var setup_actions: Array[ActionData]
@export var turn_phases: Array[Phase]


func _init(p_name: String = "", p_color := Color(),
		p_troop_sprite: Texture2D = null, p_control_banners: Texture2D = null,
		p_name_highlight_overrides: Dictionary[Color, Color] = {},
		p_setup_actions: Array[ActionData] = [],
		p_turn_phases: Array[Phase] = []) -> void:
	name = p_name
	color = p_color
	troop_sprite = p_troop_sprite
	control_banners = p_control_banners
	name_highlight_overrides = p_name_highlight_overrides
	setup_actions = p_setup_actions
	turn_phases = p_turn_phases
