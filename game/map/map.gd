class_name Map
extends Sprite2D

const Faction = Globals.Faction

const HEX_ORIGIN = Vector2(706, 442)

const PLUS_Y = Vector2(0, -32)
const PLUS_X = Vector2(28, 16)

@export var hex_scene: PackedScene

@export var game: Control
@export var territory_borders: Sprite2D

@export var continents: Array[ContinentData]

@onready var texture_size: Vector2 = texture.get_size()

var is_dragging: bool = false


func _ready() -> void:
	game.gui_input.connect(_game_input)
	get_tree().root.size_changed.connect(scale_to_fit_screen)
	scale_to_fit_screen()
	
	for continent: ContinentData in continents:
		for territory: TerritoryData in continent.territories:
			place_territory(territory)
	
	territory_borders.move_to_front()


func _game_input(event: InputEvent) -> void:
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


func place_territory(territory_data: TerritoryData) -> void:
	var territory := Territory.new(territory_data)
	add_child(territory)
	
	var tl: Vector2 = texture_size * scale * 2
	
	var hexes: Array[Hex] = []
	for pos: Vector2i in territory_data.hexes:
		hexes.append(add_hex(pos, territory))
		
		if hexes[-1].position.x < tl.x:
			tl.x = hexes[-1].position.x
		if hexes[-1].position.y < tl.y:
			tl.y = hexes[-1].position.y
	
	territory.position = tl + Vector2(1, 1)
	
	for hex: Hex in hexes:
		hex.reparent(territory)
	
	territory.add_troops(1, Faction.PIRATES)
	territory.add_troops(1, Faction.MYCOLINGS)


func add_hex(pos: Vector2i, territory: Territory) -> Hex:
	var hex: Hex = hex_scene.instantiate()
	
	territory.hexes[pos] = hex
	add_child(hex)
	
	hex.position = HEX_ORIGIN + pos.x * PLUS_X + pos.y * PLUS_Y
	
	return hex


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
