@abstract
class_name Phase
extends Resource


## Gets list of currently available actions
@abstract func _get_available_actions(actions_used: Array[ActionData],
		cleric_faith_panel: ClericFaithPanel) -> Array[ActionData]

## Gets message to display between actions
@abstract func _get_select_action_message(actions_used: Array[ActionData],
		cleric_faith_panel: ClericFaithPanel) -> String

## Checks if the phase should be over
@abstract func _is_phase_over(actions_used: Array[ActionData],
		cleric_faith_panel: ClericFaithPanel) -> bool
