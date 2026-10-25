class_name AttackData
extends ActionData


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
	var attacker: FactionData = player_bar.get_current_player()
	var attacked: FactionData = selected_players[0]
	
	attack_screen.show()
	
	attack_screen.attacker_bg.color = attacker.color
	attack_screen.attacked_bg.color = attacked.color
	attack_screen.attacker_bg.color.a = 0.75
	attack_screen.attacked_bg.color.a = 0.75
	
	attack_screen.attacker_label.text = attacker.name
	attack_screen.attacked_label.text = attacked.name
	
	var attacker_hits: int = 2
	var attacked_hits: int = 1
	
	var attacker_troops: int
	var attacked_troops: int
	attacker_troops = selected_territories[0].troop_hexes[attacker].troop_count
	attacked_troops = selected_territories[0].troop_hexes[attacked].troop_count
	attacker_troops -= attacked_hits
	attacked_troops -= attacker_hits
	
	if attacker_troops < 0:
		attacker_troops = 0
	if attacked_troops < 0:
		attacked_troops = 0
	
	attack_screen.attacker_troops_label.text = (
			"Troops left: %s" % attacker_troops)
	attack_screen.attacked_troops_label.text = (
			"Troops left: %s" % attacked_troops)
	
	await attack_screen.closed
	
	selected_territories[0].remove_troops(1, attacker)
	selected_territories[0].remove_troops(2, attacked)
	
	var attacked_lost: bool = true
	var attacker_lost: bool = true
	for continent_territories: Array in map.continents:
		for territory: Territory in continent_territories:
			if attacked in territory.troop_hexes:
				attacked_lost = false
			if attacker in territory.troop_hexes:
				attacker_lost = false
			
			if not (attacked_lost or attacker_lost): break
		
		if not (attacked_lost or attacker_lost): break
	
	if attacked_lost and attacker_lost:
		player_bar.remove_players([
			attacked,
			attacker
		])
	elif attacked_lost:
		player_bar.remove_player(attacked)
	elif attacker_lost:
		player_bar.remove_player(attacker)
