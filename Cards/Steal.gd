extends BaseCard
class_name StealCard

var mainNode: Node  # link to the Die node from the editor or dynamically
var basesToSteal = 1


func _ready():
	super._ready()
	hasDiscardEffect = true

func apply_discard_effect():
	mainNode.advance_runners_no_hit(basesToSteal)
	
		
func create_card(main: Node = null) -> Dictionary:
	mainNode = main
	var titleString = "Steal"
	var descString = "On Discard (Take Pitch) Advance Runners by " + String.num_int64(basesToSteal) + " base"
	var emptyDict:  Dictionary
	super.set_card_data(titleString, emptyDict, descString)
	description = descString
	update_ui()
	
	return emptyDict
	
		
