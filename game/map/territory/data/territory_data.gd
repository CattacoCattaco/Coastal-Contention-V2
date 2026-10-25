class_name TerritoryData
extends Resource

const Continent = Globals.Continent
const Biome = Globals.Biome

@export var continent: Continent
@export var biome: Biome
@export var hexes: Array[Vector2i]
@export_file("*.tres") var borders: Array[String]
@export var silhouette: Texture2D


func _init(p_continent: Continent = Continent.RED,
		p_biome: Biome = Biome.PLAINS, p_hexes: Array[Vector2i] = [],
		p_borders: Array[String] = [], p_silhouette: Texture2D = null) -> void:
	continent = p_continent
	biome = p_biome
	hexes = p_hexes
	borders = p_borders
	silhouette = p_silhouette
