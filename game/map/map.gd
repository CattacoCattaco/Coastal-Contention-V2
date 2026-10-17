class_name Map
extends Sprite2D

@export var game: Control

@onready var texture_size: Vector2 = texture.get_size()

var is_dragging: bool = false


func _ready() -> void:
	game.gui_input.connect(game_input)
	get_tree().root.size_changed.connect(scale_to_fit_screen)
	scale_to_fit_screen()


func scale_to_fit_screen() -> void:
	if game.size > texture_size:
		var size_ratio: Vector2 = game.size / texture_size
		var scale_factor: int = ceili(max_dimension(size_ratio))
		var old_scale: Vector2 = scale
		scale = Vector2(scale_factor, scale_factor)
		
		position *= scale / old_scale
	else:
		position /= scale
		
		scale = Vector2(1, 1)


func game_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_dragging:
			if !Input.is_action_pressed("drag"):
				is_dragging = false
				return
			
			position += event.relative
			
			clamp_pos()
			
			get_tree().root.set_input_as_handled()
	elif event.is_action("drag"):
		is_dragging = event.is_pressed()
		get_tree().root.set_input_as_handled()


func clamp_pos() -> void:
	if position.x > 0:
		position.x = 0
	elif position.x < -texture_size.x:
		position.x = -texture_size.x
	
	if position.y > 0:
		position.y = 0
	elif position.y < -texture_size.y:
		position.y = -texture_size.y


func max_dimension(vec: Vector2) -> float:
	return vec.x if vec.x >= vec.y else vec.y
