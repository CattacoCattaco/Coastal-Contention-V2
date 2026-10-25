class_name Map
extends Sprite2D

const Continent = Globals.Continent

const HEX_ORIGIN = Vector2(706, 442)

const PLUS_Y = Vector2(0, -32)
const PLUS_X = Vector2(28, 16)

signal territory_added(territory: Territory)

@export var hex_scene: PackedScene

@export var game: Control
@export var player_bar: PlayerBar
@export var victory_screen: ColorRect
@export var new_game_button: Button

@export var continents_data: Array[ContinentData]

@onready var texture_size: Vector2 = texture.get_size()

var continents: Array[Array] = []
var is_dragging: bool = false


func _ready() -> void:
	game.gui_input.connect(_game_input)
	get_tree().root.size_changed.connect(scale_to_fit_screen)
	new_game_button.pressed.connect(_reset)
	
	scale_to_fit_screen()
	
	for continent: ContinentData in continents_data:
		continents.append([])
		
		for territory: TerritoryData in continent.territories:
			continents[-1].append(place_territory(territory))
	
	setup()


func _reset() -> void:
	for continent_territories: Array in continents:
		for territory: Territory in continent_territories:
			territory.remove_all_troops()
	
	player_bar.reset_player_bar()
	setup()


func setup() -> void:
	victory_screen.hide()


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


func place_territory(territory_data: TerritoryData) -> Territory:
	var territory := Territory.new(territory_data)
	add_child(territory)
	
	var tl: Vector2 = texture_size * scale * 2
	
	var hexes: Array[Hex] = []
	for pos: Vector2i in territory_data.hexes:
		var hex: Hex = add_hex(pos)
		hexes.append(hex)
		territory.hexes[pos] = hex
		
		if hex.position.x < tl.x:
			tl.x = hex.position.x
		if hex.position.y < tl.y:
			tl.y = hex.position.y
	
	territory.biome_hex = add_hex(territory_data.biome_hex)
	territory.set_control(Globals.FACTIONS[0])
	
	territory.position = tl + Vector2(1, 1)
	
	for hex: Hex in hexes:
		hex.reparent(territory)
	
	territory.biome_hex.reparent(territory)
	
	for border_uid: String in territory_data.borders:
		var border: TerritoryData = load(border_uid)
		
		if continents.size() < border.continent + 1:
			continue
		
		for potential_match: Territory in continents[border.continent]:
			if potential_match.territory == border:
				potential_match.border_territories.append(territory)
				territory.border_territories.append(potential_match)
				break
	
	territory_added.emit(territory)
	
	return territory


func add_hex(pos: Vector2i) -> Hex:
	var hex: Hex = hex_scene.instantiate()
	
	add_child(hex)
	
	hex.z_index = -1
	hex.position = HEX_ORIGIN + pos.x * PLUS_X + pos.y * PLUS_Y
	
	return hex


func scale_to_fit_screen() -> void:
	if (get_viewport_rect().size.x > texture_size.x
			or get_viewport_rect().size.y > texture_size.y):
		var size_ratio: Vector2 = get_viewport_rect().size / texture_size
		var scale_factor: int = ceili(max_dimension(size_ratio))
		
		game.scale = Vector2(scale_factor, scale_factor)
	else:
		game.scale = Vector2(1, 1)
	
	game.custom_minimum_size = get_viewport_rect().size / game.scale
	game.custom_maximum_size = game.custom_minimum_size
	
	clamp_pos()


func clamp_pos() -> void:
	if position.x > 0:
		position.x = 0
	elif position.x < -(texture_size - game.size).x:
		position.x = -(texture_size - game.size).x
	
	if position.y > 0:
		position.y = 0
	elif position.y < -(texture_size - game.size).y:
		position.y = -(texture_size - game.size).y


func max_dimension(vec: Vector2) -> float:
	return vec.x if vec.x >= vec.y else vec.y
