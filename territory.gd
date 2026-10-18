class_name Territory
extends TextureButton

var territory: TerritoryData
var hexes: Dictionary[Vector2i, Hex] = {}


func _init(p_territory: TerritoryData) -> void:
	territory = p_territory
	
	texture_normal = territory.silhouette
	
	var click_mask := BitMap.new()
	click_mask.create_from_image_alpha(territory.silhouette.get_image())
	texture_click_mask = click_mask


func _ready() -> void:
	pass # Replace with function body.
