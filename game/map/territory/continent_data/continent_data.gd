class_name ContinentData
extends Resource

@export var territories: Array[TerritoryData]


func _init(p_territories: Array[TerritoryData] = []) -> void:
	territories = p_territories
