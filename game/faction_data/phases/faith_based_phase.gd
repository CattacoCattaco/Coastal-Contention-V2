class_name FaithBasedActionPhase
extends Phase

const Biome = Globals.Biome

@export var actions: Array[ActionData]


func _get_available_actions(actions_used: Array[ActionData],
		cleric_faith_panel: ClericFaithPanel) -> Array[ActionData]:
	var actions_available: Array[ActionData] = []
	
	for i: int in range(actions.size()):
		var biome: Biome = i as Biome
		
		var action: ActionData = actions[biome]
		if not action:
			continue
		
		var amount_used: int = actions_used.count(action)
		var amount_available: int = cleric_faith_panel.biome_faith_counts[biome]
		
		if amount_used < amount_available:
			actions_available.append(action)
	
	return actions_available


func _get_select_action_message(actions_used: Array[ActionData],
		cleric_faith_panel: ClericFaithPanel) -> String:
	var last_action: ActionData
	last_action = actions_used[-1] if actions_used else actions[0]
	
	var amount_used: int = actions_used.count(last_action)
	var biome: Biome = actions.find(last_action) as Biome
	var amount_available: int = cleric_faith_panel.biome_faith_counts[biome]
	
	var message: String = "Select action (%d/%d %ss used)" % [
		amount_used,
		amount_available,
		last_action.action_name.to_lower()
	]
	
	return message


func _is_phase_over(actions_used: Array[ActionData],
		cleric_faith_panel: ClericFaithPanel) -> bool:
	return not _get_available_actions(actions_used, cleric_faith_panel)
