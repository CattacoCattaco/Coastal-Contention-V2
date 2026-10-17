class_name Hex
extends Sprite2D

@export var troop: Sprite2D
@export var troop_count_label: Label

var troop_count: int = 0


func _ready() -> void:
	troop.hide()
	troop_count_label.hide()
	await get_tree().create_timer(3).timeout
	add_troops(2)
	await get_tree().create_timer(3).timeout
	remove_troops(1)
	await get_tree().create_timer(3).timeout
	remove_troops(5)
	await get_tree().create_timer(3).timeout
	add_troops(5)


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
