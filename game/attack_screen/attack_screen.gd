class_name AttackScreen
extends Control

signal closed

@export var attacker_bg: ColorRect
@export var attacked_bg: ColorRect
@export var attacker_label: Label
@export var attacked_label: Label
@export var attacker_hits_label: Label
@export var attacked_hits_label: Label
@export var attacker_troops_label: Label
@export var attacked_troops_label: Label
@export var continue_button: Button


func _ready() -> void:
	continue_button.pressed.connect(_close)


func _close() -> void:
	hide()
	closed.emit()
