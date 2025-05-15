extends BaseCard
class_name ContactCard

func create_card() -> void:
	var descString = "+50% to hit"
	var titleString = "Contact Swing"
	super.set_card_data(titleString, descString, 50,50)
