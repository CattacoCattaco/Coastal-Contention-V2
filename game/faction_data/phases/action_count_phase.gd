class_name ActionCountPhase
extends Phase

@export var action_count: int
@export var actions: Array[ActionData]


func _get_available_actions(_actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> Array[ActionData]:
	return actions


func _get_select_action_message(actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> String:
	var message: String = "Select action (%d/%d actions used)"
	message %= [actions_used.size(), action_count]
	return message


func _is_phase_over(actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> bool:
	return actions_used.size() == action_count
