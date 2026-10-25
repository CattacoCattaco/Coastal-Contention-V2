class_name Hex
extends Sprite2D

@export var control_banners: Sprite2D
@export var troop: Sprite2D
@export var troop_count_label: Label

var troop_count: int = 0


func _ready() -> void:
	control_banners.hide()
	troop.hide()
	troop_count_label.hide()


func set_control(faction: FactionData) -> void:
	control_banners.show()
	control_banners.texture = faction.control_banners


func remove_control() -> void:
	control_banners.hide()


func set_faction(faction: FactionData) -> void:
	troop.texture = faction.troop_sprite


func add_troops(count: int) -> void:
	troop.show()
	troop_count_label.show()
	
	troop_count += count
	troop_count_label.text = str(troop_count)


func remove_troops(count: int) -> void:
	troop_count -= count
	
	if troop_count <= 0:
		troop_count = 0
		troop.hide()
		troop_count_label.hide()
	
	troop_count_label.text = str(troop_count)


func is_empty() -> bool:
	return troop_count == 0
