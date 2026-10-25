class_name OptionsScreen
extends ColorRect

enum MapSizing {
	COVER,
	FIT,
}

signal map_sizing_selected(sizing: MapSizing)
signal players_selected(players: Array[FactionData])
signal options_selected

@export var map_size_options: OptionButton
@export var player_count_box: SpinBox
@export var player_faction_labels: Array[Label]
@export var player_faction_options: Array[OptionButton]
@export var start_button: Button

var player_of_faction_index: Array[OptionButton] = []
var player_faction_indeces: Dictionary[OptionButton, int] = {}


func _ready() -> void:
	player_count_box.value_changed.connect(_player_count_changed)
	_player_count_changed(2.0)
	
	for i in range(player_faction_options.size()):
		player_faction_options[i].select(i)
		
		player_of_faction_index.append(player_faction_options[i])
		player_faction_indeces[player_faction_options[i]] = i
		
		player_faction_options[i].item_selected.connect(
				_player_faction_option_changed.bind(i))
	
	start_button.pressed.connect(_start_button_pressed)


func _player_count_changed(new_valuef: float) -> void:
	var new_value: int = roundi(new_valuef)
	
	for i in range(new_value):
		player_faction_labels[i].show()
		player_faction_options[i].show()
	for i in range(new_value, player_faction_labels.size()):
		player_faction_labels[i].hide()
		player_faction_options[i].hide()


func _player_faction_option_changed(new_faction_index: int, player_index: int
		) -> void:
	var this: OptionButton = player_faction_options[player_index]
	var other: OptionButton = player_of_faction_index[new_faction_index]
	var old_faction_index: int = player_faction_indeces[this]
	
	other.select(old_faction_index)
	
	player_of_faction_index[new_faction_index] = this
	player_of_faction_index[old_faction_index] = other
	player_faction_indeces[this] = new_faction_index
	player_faction_indeces[other] = old_faction_index


func _start_button_pressed() -> void:
	hide()
	
	map_sizing_selected.emit(map_size_options.get_selected_id() as MapSizing)
	
	var players: Array[FactionData] = []
	
	for i in range(roundi(player_count_box.value)):
		var faction_index: int = player_faction_options[i].get_selected_id()
		players.append(Globals.FACTIONS[faction_index])
	
	players_selected.emit(players)
	
	options_selected.emit()
