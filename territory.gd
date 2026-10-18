class_name Territory
extends TextureButton

const Faction = Globals.Faction

var territory: TerritoryData
var hexes: Dictionary[Vector2i, Hex] = {}
var troop_hexes: Dictionary[Faction, Hex] = {}
var border_territories: Array[Territory] = []

var is_down: bool = false


func _init(p_territory: TerritoryData) -> void:
	territory = p_territory
	
	texture_normal = territory.silhouette
	
	var click_mask := BitMap.new()
	click_mask.create_from_image_alpha(territory.silhouette.get_image())
	texture_click_mask = click_mask


func _ready() -> void:
	z_index = 5
	
	self_modulate.a = .5 if is_hovered() else 0.0
	
	button_down.connect(_button_down)
	button_up.connect(_button_up)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)


func add_troops(count: int, faction: Faction) -> void:
	if faction in troop_hexes:
		troop_hexes[faction].add_troops(count)
	else:
		for hex: Hex in hexes.values():
			if hex.is_empty():
				hex.set_faction(faction)
				hex.add_troops(count)
				troop_hexes[faction] = hex
				break


func remove_all_troops() -> void:
	for faction: Faction in troop_hexes:
		remove_troops(troop_hexes[faction].troop_count, faction)


func remove_troops(count: int, faction: Faction) -> void:
	if faction in troop_hexes:
		troop_hexes[faction].remove_troops(count)
		if troop_hexes[faction].troop_count == 0:
			troop_hexes.erase(faction)


func _button_down() -> void:
	is_down = true
	
	self_modulate.a = .75


func _button_up() -> void:
	is_down = false
	
	self_modulate.a = .5 if is_hovered() else 0.0


func _mouse_entered() -> void:
	self_modulate.a = .75 if is_down else .5


func _mouse_exited() -> void:
	self_modulate.a = .75 if is_down else 0.0
