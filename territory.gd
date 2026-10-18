class_name Territory
extends TextureButton

var territory: TerritoryData
var hexes: Dictionary[Vector2i, Hex] = {}

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
