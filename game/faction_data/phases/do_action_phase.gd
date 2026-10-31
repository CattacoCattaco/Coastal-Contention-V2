class_name DoActionPhase
extends Phase

@export var action: ActionData
@export var is_optional: bool


func _get_available_actions(_actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> Array[ActionData]:
	return [action]


func _get_select_action_message(_actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> String:
	return ""


func _is_phase_over(actions_used: Array[ActionData],
		_cleric_faith_panel: ClericFaithPanel) -> bool:
	return not not actions_used
