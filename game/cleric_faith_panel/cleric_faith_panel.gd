class_name ClericFaithPanel
extends ColorRect

const Biome = Globals.Biome
const BIOME_ACTION_NAMES: Array[String] = [
	"Move",
	"None",
	"Attack",
	"Recruit",
]

@export var labels: Array[Label]

var biome_faith_counts: Array[int] = []


func _ready() -> void:
	for i in range(labels.size()):
		biome_faith_counts.append(0)


func add_faith(biome: Biome) -> void:
	biome_faith_counts[biome] += 1
	update_faith(biome)


func remove_faith(biome: Biome) -> void:
	biome_faith_counts[biome] -= 1
	update_faith(biome)


func update_faith(biome: Biome) -> void:
	labels[biome].text = "%s (%s): %d" % [
		Globals.BIOME_NAMES[biome],
		BIOME_ACTION_NAMES[biome],
		biome_faith_counts[biome],
	]
