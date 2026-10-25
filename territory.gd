class_name Territory
extends TextureButton

const SHADER = preload("res://shaders/outline.gdshader")

var territory: TerritoryData
var shader_material: ShaderMaterial
var hexes: Dictionary[Vector2i, Hex] = {}
var troop_hexes: Dictionary[FactionData, Hex] = {}
var biome_hex: Hex
var border_territories: Array[Territory] = []
var controller: FactionData = null

var is_down: bool = false


func _init(p_territory: TerritoryData) -> void:
	territory = p_territory
	
	texture_normal = territory.silhouette
	
	var click_mask := BitMap.new()
	click_mask.create_from_image_alpha(territory.silhouette.get_image())
	texture_click_mask = click_mask
	
	shader_material = ShaderMaterial.new()
	shader_material.shader = SHADER
	shader_material.set_shader_parameter("use_override_opaque_color", true)
	material = shader_material


func _ready() -> void:
	z_index = 5
	
	await RenderingServer.frame_post_draw
	
	shader_material.set_shader_parameter("size_pixels", size)
	set_fill_alpha(.5 if is_hovered() else 0.0)
	
	button_down.connect(_button_down)
	button_up.connect(_button_up)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func set_control(faction: FactionData) -> void:
	controller = faction
	biome_hex.set_control(faction)


func remove_control() -> void:
	controller = null
	biome_hex.remove_control()


func add_troops(count: int, faction: FactionData) -> void:
	if faction in troop_hexes:
		troop_hexes[faction].add_troops(count)
	else:
		for hex: Hex in hexes.values():
			if hex.is_empty():
				hex.set_faction(faction)
				hex.add_troops(count)
				troop_hexes[faction] = hex
				break
	
	if faction != controller:
		var new_controller: FactionData = _get_new_controller()
		
		if new_controller == faction:
			set_control(new_controller)


func remove_all_troops() -> void:
	var start_controller: FactionData = controller
	
	for faction: FactionData in troop_hexes:
		remove_troops(troop_hexes[faction].troop_count, faction)
	
	controller = start_controller


func remove_troops(count: int, faction: FactionData) -> void:
	if faction in troop_hexes:
		troop_hexes[faction].remove_troops(count)
		if troop_hexes[faction].troop_count == 0:
			troop_hexes.erase(faction)
		
		if faction == controller:
			var new_controller: FactionData = _get_new_controller()
			
			if new_controller and new_controller != faction:
				set_control(new_controller)


func _get_new_controller() -> FactionData:
	var most_troops: int = 0
	var new_controller: FactionData = null
	
	for faction: FactionData in troop_hexes:
		var troop_count: int = troop_hexes[faction].troop_count
		if troop_count > most_troops:
			most_troops = troop_count
			new_controller = faction
		elif troop_count == most_troops:
			new_controller = null
	
	return new_controller


func _button_down() -> void:
	is_down = true
	
	set_fill_alpha(.75)


func _button_up() -> void:
	is_down = false
	
	set_fill_alpha(.5 if is_hovered() else 0.0)


func _mouse_entered() -> void:
	set_fill_alpha(.75 if is_down else .5)


func _mouse_exited() -> void:
	set_fill_alpha(.75 if is_down else 0.0)


func set_outline_color(color: Color) -> void:
	shader_material.set_shader_parameter("outline_color", color)


func set_fill_alpha(alpha: float) -> void:
	var color := Color("#394a50")
	color.a = alpha
	shader_material.set_shader_parameter("override_opaque_color", color)
