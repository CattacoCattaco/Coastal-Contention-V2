class_name AttackData
extends ActionData

const MAX_ATTACKER_DICE: int = 4
const MAX_DEFENDER_DICE: int = 6
const ATTACKER_HIT_MIN: int = 3
const DEFENDER_HIT_MIN: int = 4


func _init(p_outline_color := Color(), p_stage_count: int = 2,
		p_action_name: String = "Attack") -> void:
	super(p_outline_color, p_stage_count, p_action_name)


func _get_stage_input(stage: int) -> StageInput:
	match stage:
		1:
			return StageInput.TERRITORY_SELECT
		2:
			return StageInput.PLAYER_SELECT
	
	return StageInput.ERROR


func _get_stage_instruction(stage: int) -> String:
	match stage:
		1:
			return "Choose territory to attack in"
		2:
			return "Choose player to attack"
	
	return ""


func _get_selectable_territories(map: Map, player_bar: PlayerBar, stage: int,
		_selected_territories: Array[Territory]) -> Array[Territory]:
	var territories: Array[Territory] = []
	
	if stage == 1:
		for continent: Array in map.continents:
			for territory: Territory in continent:
				if territory.troop_hexes.size() < 2:
					continue
				if player_bar.get_current_player() not in territory.troop_hexes:
					continue
				
				territories.append(territory)
	
	return territories


func _get_selectable_players(player_bar: PlayerBar, stage: int,
		selected_territories: Array[Territory]) -> Array[FactionData]:
	var factions: Array[FactionData] = []
	
	if stage == 2:
		for faction: FactionData in player_bar.players:
			if faction not in selected_territories[0].troop_hexes:
				continue
			if faction == player_bar.get_current_player():
				continue
			
			factions.append(faction)
	
	return factions


func _get_action_menu(_stage: int) -> ActionMenu:
	return ActionMenu.ERROR


func _do_action(selected_territories: Array[Territory],
		selected_players: Array[FactionData], map: Map,
		_troop_count_box: SpinBox, player_bar: PlayerBar,
		attack_screen: AttackScreen) -> void:
	attack_screen.attacker_hits_label.text = "Hits: --"
	attack_screen.defender_hits_label.text = "Hits: --"
	
	attack_screen.attacker_troops_label.text = "Troops left: --"
	attack_screen.defender_troops_label.text = "Troops left: --"
	
	var attacker: FactionData = player_bar.get_current_player()
	var defender: FactionData = selected_players[0]
	
	var attacker_troops: int
	var defender_troops: int
	attacker_troops = selected_territories[0].troop_hexes[attacker].troop_count
	defender_troops = selected_territories[0].troop_hexes[defender].troop_count
	
	attack_screen.show()
	
	attack_screen.attacker_bg.color = attacker.color
	attack_screen.defender_bg.color = defender.color
	attack_screen.attacker_bg.color.a = 0.75
	attack_screen.defender_bg.color.a = 0.75
	
	attack_screen.attacker_label.text = attacker.name
	attack_screen.defender_label.text = defender.name
	
	var attacker_dice: int = min(attacker_troops, MAX_ATTACKER_DICE)
	var defender_dice: int = min(defender_troops, MAX_DEFENDER_DICE)
	await attack_screen.roll_dice(attacker_dice, defender_dice)
	
	var attacker_hits: int = 0
	var defender_hits: int = 0
	
	for i in range(attacker_dice):
		if attack_screen.attacker_rolls[i] >= ATTACKER_HIT_MIN:
			attacker_hits += 1
	for i in range(defender_dice):
		if attack_screen.defender_rolls[i] >= DEFENDER_HIT_MIN:
			defender_hits += 1
	
	attack_screen.attacker_hits_label.text = "Hits: %s" % attacker_hits
	attack_screen.defender_hits_label.text = "Hits: %s" % defender_hits
	
	attacker_troops -= defender_hits
	defender_troops -= attacker_hits
	
	if attacker_troops < 0:
		attacker_troops = 0
	if defender_troops < 0:
		defender_troops = 0
	
	var attacker_troops_text: String = "Troops left: %s" % attacker_troops 
	var defender_troops_text: String = "Troops left: %s" % defender_troops
	
	attack_screen.attacker_troops_label.text = attacker_troops_text
	attack_screen.defender_troops_label.text = defender_troops_text
	
	await attack_screen.closed
	
	selected_territories[0].remove_troops(1, attacker)
	selected_territories[0].remove_troops(2, defender)
	
	var defender_lost: bool = true
	var attacker_lost: bool = true
	for continent_territories: Array in map.continents:
		for territory: Territory in continent_territories:
			if defender in territory.troop_hexes:
				defender_lost = false
			if attacker in territory.troop_hexes:
				attacker_lost = false
			
			if not (defender_lost or attacker_lost): break
		
		if not (defender_lost or attacker_lost): break
	
	if defender_lost and attacker_lost:
		player_bar.remove_players([
			defender,
			attacker
		])
	elif defender_lost:
		player_bar.remove_player(defender)
	elif attacker_lost:
		player_bar.remove_player(attacker)
