class_name AttackScreen
extends Control

signal closed

const DIE_SPRITES: Array[Texture2D] = [
	preload("res://game/attack_screen/dice/die_1.png"),
	preload("res://game/attack_screen/dice/die_2.png"),
	preload("res://game/attack_screen/dice/die_3.png"),
	preload("res://game/attack_screen/dice/die_4.png"),
	preload("res://game/attack_screen/dice/die_5.png"),
	preload("res://game/attack_screen/dice/die_6.png"),
]

@export var attacker_bg: ColorRect
@export var attacked_bg: ColorRect
@export var attacker_label: Label
@export var attacked_label: Label
@export var attacker_dice_holder: GridContainer
@export var attacked_dice_holder: GridContainer
@export var attacker_hits_label: Label
@export var attacked_hits_label: Label
@export var attacker_troops_label: Label
@export var attacked_troops_label: Label
@export var continue_button: Button

var attacker_rolls: Array[int] = []
var attacked_rolls: Array[int] = []


func _ready() -> void:
	continue_button.pressed.connect(_close)


func _close() -> void:
	hide()
	closed.emit()


func roll_dice(attacker_count: int, attacked_count: int) -> void:
	continue_button.hide()
	
	var attacker_dice: Array[TextureRect] = []
	var attacked_dice: Array[TextureRect] = []
	
	attacker_rolls = []
	attacked_rolls = []
	
	var attacker_roll_frame_counts: Array[int] = []
	var attacked_roll_frame_counts: Array[int] = []
	
	for i in range(attacker_count):
		var die: TextureRect = create_die()
		attacker_dice.push_back(die)
		attacker_dice_holder.add_child(die)
		
		var frame_count: int = randi_range(10, 20)
		attacker_roll_frame_counts.append(frame_count)
		attacker_rolls.push_back(0)
		
		roll_die(die, frame_count, attacker_rolls, i)
	
	for i in range(attacked_count):
		var die: TextureRect = create_die()
		attacked_dice.push_back(die)
		attacked_dice_holder.add_child(die)
		
		var frame_count: int = randi_range(10, 20)
		attacked_roll_frame_counts.append(frame_count)
		attacked_rolls.push_back(0)
		
		roll_die(die, frame_count, attacked_rolls, i)
	
	await get_tree().create_timer(4.5).timeout
	
	var unrolled_dice: bool = true
	while unrolled_dice:
		unrolled_dice = false
		
		for roll: int in attacker_rolls:
			if roll == 0:
				unrolled_dice = true
				break
		
		if not unrolled_dice:
			for roll: int in attacked_rolls:
				if roll == 0:
					unrolled_dice = true
					break
		
		if unrolled_dice:
			await get_tree().create_timer(0.25).timeout
	
	continue_button.show()


func create_die() -> TextureRect:
	var die := TextureRect.new()
	
	die.texture = DIE_SPRITES[0]
	
	die.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	die.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	die.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	return die


func roll_die(die: TextureRect, frame_count: int, rolls_list: Array[int],
		roll_index: int) -> void:
	var roll: int
	
	for i in range(frame_count):
		roll = randi_range(1, 6)
		die.texture = DIE_SPRITES[roll - 1]
		var frame_length: float = get_roll_frame_length_sec(i, frame_count)
		await get_tree().create_timer(frame_length).timeout
	
	roll = randi_range(1, 6)
	die.texture = DIE_SPRITES[roll - 1]
	
	rolls_list[roll_index] = roll


func get_total_roll_length_sec(count: int) -> float:
	var sum: float = 0
	
	for i in range(count):
		sum += get_roll_frame_length_sec(i, count)
	
	return sum


func get_roll_frame_length_sec(index: int, count: int) -> float:
	return 2.0 / (count - index + 2.0)
