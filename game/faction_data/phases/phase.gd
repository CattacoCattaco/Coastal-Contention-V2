@abstract
class_name Phase
extends Resource


## Gets list of currently available actions
@abstract func _get_available_actions() -> Array[ActionData]

## Gets message to display between actions
@abstract func _get_select_action_message(actions_used: Array[ActionData]
		) -> String

## Checks if the phase should be over
@abstract func _is_phase_over(actions_used: Array[ActionData]) -> bool
