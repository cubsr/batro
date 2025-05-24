extends Control

var CardScene = preload("res://Card.tscn")
var CardHolderScene = preload("res://CardHolder.tscn")
var ContactCardScene = preload("res://Cards/ContactCard.tscn")
var handSize = 5
var playerhand
@onready var main_swing_grid = $SwingGrid
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

var deck := []

func _ready():
	playerhand = $BottomPanel/PlayerHand
	buildStarterDeck()
	deck.shuffle()
	for i in range(handSize):
		var holder = CardHolderScene.instantiate()
		var card = deck[0]["cardObject"]
		holder.add_child(card)
		playerhand.add_child(holder)
		card.apply_zone_colors(deck[0]["coloredZones"])
		deck.remove_at(0)
		
func light_up_base(index: int):
	for i in range(bases.size()):
		bases[i].modulate = Color(1, 1, 1)  # reset all
	bases[index].modulate = Color(1.2, 1.2, 0.5)
		
func buildStarterDeck():
	for i in range(6):
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

	


func _on_play_button_pressed() -> void:
	var selected_wrappers = []

	for child in playerhand.get_children():
		for card in child.get_children():
			if card.is_selected:
				var wrapper = card.get_parent()
				selected_wrappers.append(wrapper)

	for wrapper in selected_wrappers:
		playerhand.remove_child(wrapper)
		wrapper.queue_free()
		
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
