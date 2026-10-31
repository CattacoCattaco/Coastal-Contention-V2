class_name UnlimitedPhase
extends Phase

@export var actions: Array[ActionData]


func _get_available_actions(_actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> Array[ActionData]:
	return actions


func _get_select_action_message(_actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> String:
	return "Select action"


func _is_phase_over(_actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> bool:
	return false
