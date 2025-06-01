extends Control

var lockInteraction = false
var CardScene = preload("res://Card.tscn")
var CardHolderScene = preload("res://CardHolder.tscn")
var ContactCardScene = preload("res://Cards/ContactCard.tscn")
var handSize = 5
var playerhand
@onready var main_swing_grid = $SwingGrid
@onready var atBatinfo = $ScoreBug/AtBatInfo
@onready var scoreInfo = $ScoreBug/Scores
var hitTypeColors := {
	"Neutral": Color("gray"),
	"Single": Color("#1EFF00"),
	"Double": Color("#0070FF"),
	"Triple": Color("#A335EE"),
	"Homer": Color("#FF8000"),
	"Negative": Color("#FF3B3B")
	}
	
var hitTypestoNumber := {
	"Neutral": 0,
	"Single": 1,
	"Double": 2,
	"Triple": 3,
	"Homer": 4,
	"Negative": -1
	}

@onready var bases = [
	$Bases/FirstBase,
	$Bases/SecondBase,
	$Bases/ThirdBase,
	$Bases/HomeBase
]
var menOnBase = [
	0,
	0,
	0,
	0
]

var deck := []
var discard := []

var runner_scene = preload("res://RunnerRunning.tscn")
var runner_pool = []
var runner_at_base = [null, null, null, null]

func _ready():
	playerhand = $BottomPanel/PlayerHand
	buildStarterDeck()
	deck.shuffle()
	draw_cards(handSize)
	atBatinfo.setup()
	scoreInfo.set_target_score(15)
	for i in range(9):
		main_swing_grid.get_child(i).color = Color("gray")
	# Preload your runner sprite scene (e.g., a RunnerRunning.tscn)

	for i in range(4):
		var runner = runner_scene.instantiate()
		$Runners.add_child(runner)
		runner_pool.append(runner)
		
func draw_cards(amount: int):
	for i in range(amount):
		if(deck.is_empty()):
			deck = discard
			discard = []
			deck.shuffle()
		var holder = CardHolderScene.instantiate()
		var card = deck[0]["cardObject"]
		holder.add_child(card)
		playerhand.add_child(holder)
		card.apply_zone_colors(deck[0]["coloredZones"])
		discard.append(deck[0])
		deck.remove_at(0)
		
		
func light_up_base(index: int):
	var time = 1.0
	if index > 3:
		index = 3
		time = time/2
		var tweentoGrey = create_tween()
		tweentoGrey.tween_property(bases[index], "modulate", Color(0.5, 0.5, 0.5, 1.0), time)
	var tween = create_tween()
	tween.tween_property(bases[index], "modulate", Color(1, 1, 1, 1), time)
	
func grey_out_bases():
	var time = 1.0
	for i in range(4):
		var tweentoGrey = create_tween()
		tweentoGrey.tween_property(bases[i], "modulate", Color(0.5, 0.5, 0.5, 1.0), time)
		
func buildStarterDeck():
	for i in range(40):
		var card = ContactCardScene.instantiate()
		card.connect("show_popup", Callable($InfoPopup, "show_info"))
		card.connect("hide_popup", Callable($InfoPopup, "hide_info"))
		card.connect("card_selected", Callable(self, "update_main_swing_grid"))
		var zoneWithHitType = card.create_card()
		var card_entry = {
		"cardObject": card,
		"coloredZones": zoneWithHitType
		}
		deck.append(card_entry)

	
func takePitchPressed() -> void:
	if lockInteraction:
		return
	var selected_wrappers = []
	var roll = randi_range(0, 12)
	var playedCards = 0
	for child in playerhand.get_children():
		for card in child.get_children():
			if card.is_selected:
				playedCards = playedCards + 1
				var wrapper = card.get_parent()
				selected_wrappers.append(wrapper)
	for wrapper in selected_wrappers:
		playerhand.remove_child(wrapper)
		wrapper.queue_free()
	if roll < 9:
		atBatinfo.add_strike()
	else:
		atBatinfo.add_ball()
		
	if atBatinfo.getStrikesLights()	> 2:
		if atBatinfo.getOutsLights() > 1:
			$Lose.visible = true
		atBatinfo.update_lights(atBatinfo.getOutsLights() + 1, 0, 0)
	elif atBatinfo.getBallsLights() > 3:
		advance_runnersWalk(1)
		lockInteraction = true
		atBatinfo.update_lights(atBatinfo.getOutsLights(), 0, 0)
		lockInteraction = false
		
	clear_swing_zone()
	draw_cards(playedCards)
	
func _on_play_button_pressed() -> void:
	if lockInteraction:
		return
	var selected_wrappers = []
	var roll = randi_range(0, 12)
	print(roll, " rolled")
	var hit = false
	var base
	var playedCards = 0

	for child in playerhand.get_children():
		for card in child.get_children():
			if card.is_selected:
				playedCards = playedCards + 1
				var wrapper = card.get_parent()
				selected_wrappers.append(wrapper)

	for wrapper in selected_wrappers:
		playerhand.remove_child(wrapper)
		wrapper.queue_free()
	if roll < 9:
		var zone = main_swing_grid.get_child(roll)
		var hitType = hitTypeColors.find_key(zone.color)
		base = hitTypestoNumber[hitType]
		if base > 0:
			hit = true
			
	if hit:
		print("HIT")
		print(hitTypestoNumber.find_key(base))
		advance_runners(base)
		atBatinfo.update_lights(atBatinfo.getOutsLights(), 0, 0)
	else:
		atBatinfo.add_strike()
		print("miss")
			
	if atBatinfo.getStrikesLights()	> 2:
		if atBatinfo.getOutsLights() > 1:
			$Lose.visible = true
		await get_tree().create_timer(1.0).timeout
		
		atBatinfo.update_lights(atBatinfo.getOutsLights() + 1, 0, 0)
	clear_swing_zone()
	draw_cards(playedCards)
		
		
func clear_swing_zone():
	for i in range(9):
		main_swing_grid.get_child(i).color = hitTypeColors["Neutral"]
		
			
func update_base_visuals():
	for i in range(bases.size()):
		if menOnBase[i] > 0:
			bases[i].modulate = Color(1, 1, 1)  # White for occupied
		else:
			bases[i].modulate = Color(0.5, 0.5, 0.5)  # Dimmed when empty
			
		
func update_main_swing_grid():
	# Reset all zones to gray
	for i in range(9):
		main_swing_grid.get_child(i).color = Color("gray")
		
	# Initialize an array to track summed colors
	var summed_colors = []
	for i in range(9):
		summed_colors.append(0)
	
	# Go through selected cards
	for child in playerhand.get_children():
		for card in child.get_children():
			if card.is_selected:
				var card_colors = card.zonesHits
				for index in card_colors.keys():
					var hit_type = card_colors[index]
					summed_colors[index] = summed_colors[index] + hitTypestoNumber[hit_type]
	
	# Clean up data
	for i in range(9):
		if summed_colors[i] < -1:
			summed_colors[i] = -1
		elif summed_colors[i] > 4:
			summed_colors[i] = 4
		main_swing_grid.get_child(i).color = hitTypeColors[hitTypestoNumber.find_key(summed_colors[i])]
		
var runner_running 
var moving_runners = []

func advance_runnersWalk(amount: int):
	var runners_to_move = []
	var newManonBase = [0, 0, 0, 0]
	newManonBase[amount - 1] = 1

	# Create batter runner at Home (index 3 in bases array)
	var batter_runner = _get_free_runner()
	if batter_runner:
		var spot = bases[3].get_node("RunnerSpot")
		batter_runner.global_position = spot.global_position
		batter_runner.visible = true
		runner_at_base[3] = batter_runner
		runners_to_move.append({
				"runner": runner_at_base[3],
				"from_index": 3,
				"to_index": amount - 1
			})
	print("menOnBase before other runner check: ", menOnBase)
	
	var chainedRunner = true
	var inspectingBase = 0
	var lastBaseMoved = -1
	while chainedRunner:
		if menOnBase[inspectingBase] > 0 and runner_at_base[inspectingBase] and inspectingBase < 3:
			var target = min(inspectingBase + amount, 3)
			runners_to_move.append({
				"runner": runner_at_base[inspectingBase],
				"from_index": inspectingBase,
				"to_index": target
			})
			runner_at_base[inspectingBase] = null
			menOnBase[inspectingBase] = 0
			newManonBase[target] += 1
			runner_at_base[target] = runners_to_move[-1]["runner"]
			lastBaseMoved = inspectingBase
		if inspectingBase > 2 or inspectingBase - amount > lastBaseMoved:
			chainedRunner = false
		inspectingBase = inspectingBase + 1
		
	menOnBase = 	newManonBase
	# Move runners
	for move_data in runners_to_move:
		move_runner_between_bases(move_data["runner"], move_data["from_index"], move_data["to_index"])

	print("menOnBase after move: ", menOnBase)
	update_base_visuals() 
		
func advance_runners(amount: int):
	var runners_to_move = []
	var newManonBase = [0, 0, 0, 0]
	newManonBase[amount - 1] = 1

	# Create batter runner at Home (index 3 in bases array)
	var batter_runner = _get_free_runner()
	if batter_runner:
		var spot = bases[3].get_node("RunnerSpot")
		batter_runner.global_position = spot.global_position
		batter_runner.visible = true
		runner_at_base[3] = batter_runner
		runners_to_move.append({
				"runner": runner_at_base[3],
				"from_index": 3,
				"to_index": amount - 1
			})
	print("menOnBase before other runner check: ", menOnBase)
	# Plan runner moves
	for i in range(3, -1, -1):
		if menOnBase[i] > 0 and runner_at_base[i]:
			var target = min(i + amount, 3)
			runners_to_move.append({
				"runner": runner_at_base[i],
				"from_index": i,
				"to_index": target
			})
			runner_at_base[i] = null
			menOnBase[i] = 0
			newManonBase[target] += 1
			runner_at_base[target] = runners_to_move[-1]["runner"]
	menOnBase = 	newManonBase
	# Move runners
	for move_data in runners_to_move:
		move_runner_between_bases(move_data["runner"], move_data["from_index"], move_data["to_index"])

	print("menOnBase after move: ", menOnBase)
	update_base_visuals() 
	
func _get_free_runner() -> Node2D:
	for runner in runner_pool:
		if runner.isFreeRunner():
			print("foundRunner ", runner)
			return runner
	return null  # Optional: handle case where all runners are busy

func move_runner_between_bases(runner: Node2D, from_index: int, to_index: int):
	var path = []
	if from_index < to_index:
		for i in range(from_index + 1, to_index + 1):
			path.append(bases[i])
	else:
		print("from_index ", from_index, "to_index ", to_index)
		path.append(bases[3])
		print("path.append(bases[",3,"])")
		for i in range(0, to_index + 1):
			print("path.append(bases[",i,"])")
			path.append(bases[i])

	if path.is_empty():
		print("No path for runner from", from_index, "to", to_index)
		return

	print("Moving runner from", from_index, "to", to_index, "via", path)
	_animate_runner_to_next_base(runner, path, to_index)

func _animate_runner_to_next_base(runner: Node2D, path: Array, finalBase: int):
	if path.is_empty():
		runner.show_standing()  # Switch to standing at destination
		var old_index = runner_at_base.find(runner)
		if old_index != -1:
			runner_at_base[old_index] = null
			menOnBase[old_index] = 0

		if finalBase == 3:
			scoreInfo.add_score(1)
			runner.hide_runner()
		else:
			runner_at_base[finalBase] = runner
			menOnBase[finalBase] = 1
		print("Runner arrived at base:", finalBase)
		print("Updated menOnBase:", menOnBase)
		return

	runner.show_running()  # Ensure runner is running while moving
	var next_base = path.pop_front()
	var tween = get_tree().create_tween()
	tween.tween_property(runner, "global_position", next_base.global_position, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_on_runner_arrived").bind(runner, path, finalBase))

func _on_runner_arrived(runner: Node2D, path: Array, finalBase):
	_animate_runner_to_next_base(runner, path, finalBase)
	
	
