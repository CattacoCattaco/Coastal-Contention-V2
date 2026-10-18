class_name TerritoryData
extends Resource

@export var hexes: Array[Vector2i]
@export_file("*.tres") var borders: Array[String]
@export var silhouette: Texture2D


func _init(p_hexes: Array[Vector2i] = [], p_silhouette: Texture2D = null
		) -> void:
	hexes = p_hexes
	silhouette = p_silhouette
