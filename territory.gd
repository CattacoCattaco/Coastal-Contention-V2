class_name Territory
extends TextureButton

const SHADER = preload("res://shaders/outline.gdshader")

var territory: TerritoryData
var shader_material: ShaderMaterial
var hexes: Dictionary[Vector2i, Hex] = {}
var troop_hexes: Dictionary[FactionData, Hex] = {}
var token_hexes: Dictionary[FactionData, Array] = {}
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


func has_token(sprite: Texture2D, faction: FactionData) -> bool:
	if faction not in token_hexes:
		return false
	
	for hex: Hex in token_hexes[faction]:
		if hex.has_token(sprite):
			return true
	
	return false


func add_troops(count: int, faction: FactionData) -> void:
	if faction in troop_hexes:
		troop_hexes[faction].add_troops(count)
	else:
		for hex: Hex in hexes.values():
			if not hex.is_empty():
				continue
			
			hex.set_faction(faction)
			hex.add_troops(count)
			troop_hexes[faction] = hex
			break
	
	if faction != controller:
		var new_controller: FactionData = _get_new_controller()
		
		if new_controller == faction:
			set_control(new_controller)


func add_token(sprite: Texture2D, faction: FactionData) -> void:
	for hex: Hex in hexes.values():
		if not hex.is_empty():
			continue
		
		hex.set_token(sprite, faction)
		
		if faction not in token_hexes:
			token_hexes[faction] = []
		
		token_hexes[faction].append(hex)
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
	if faction not in troop_hexes:
		return
	
	troop_hexes[faction].remove_troops(count)
	if troop_hexes[faction].troop_count == 0:
		troop_hexes.erase(faction)
	
	if faction == controller:
		var new_controller: FactionData = _get_new_controller()
		
		if new_controller and new_controller != faction:
			set_control(new_controller)


func remove_token(sprite: Texture2D, faction: FactionData) -> void:
	if faction not in token_hexes:
		return
	
	for hex: Hex in token_hexes[faction]:
		if hex.token.texture != sprite:
			continue
		
		hex.remove_token()
		token_hexes[faction].erase(hex)
	
	if faction == controller:
		var new_controller: FactionData = _get_new_controller()
		
		if new_controller and new_controller != faction:
			set_control(new_controller)


func replace_token(old_sprite: Texture2D, new_sprite: Texture2D,
		faction: FactionData) -> void:
	if faction not in token_hexes:
		return
	
	for hex: Hex in token_hexes[faction]:
		if hex.token.texture != old_sprite:
			continue
		
		hex.token.texture = new_sprite


func _get_new_controller() -> FactionData:
	var most_pieces: int = 0
	var new_controller: FactionData = null
	
	for faction: FactionData in troop_hexes:
		var piece_count: int = troop_hexes[faction].troop_count
		
		if faction in token_hexes:
			piece_count += token_hexes[faction].size()
		
		if piece_count > most_pieces:
			most_pieces = piece_count
			new_controller = faction
		elif piece_count == most_pieces:
			new_controller = null
	
	for faction: FactionData in token_hexes:
		var token_count: int = token_hexes[faction].size()
		
		if token_count > most_pieces:
			most_pieces = token_count
			new_controller = faction
		elif token_count == most_pieces:
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
