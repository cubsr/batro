extends Control

var CardScene = preload("res://Card.tscn")
var CardHolderScene = preload("res://CardHolder.tscn")
var ContactCardScene = preload("res://Cards/ContactCard.tscn")
var handSize = 5
var playerhand

@onready var bases = [
	$Bases/FirstBase,
	$Bases/SecondBase,
	$Bases/ThirdBase,
	$Bases/HomeBase
]

var deck = [
]

func _ready():
	playerhand = $BottomPanel/PlayerHand
	buildStarterDeck()
	deck.shuffle()
	for i in range(handSize):
		var holder = CardHolderScene.instantiate()
		holder.add_child(deck[0])
		playerhand.add_child(holder)
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
		card.create_card()
		deck.append(card)

	


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
