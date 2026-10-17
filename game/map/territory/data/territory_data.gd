class_name TerritoryData
extends Resource

@export var hexes: Array[Vector2i]


func _init(p_hexes: Array[Vector2i] = []) -> void:
	hexes = p_hexes
