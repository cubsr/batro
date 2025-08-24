extends BaseCard
class_name ShuffleCard

@export var die_node_path: NodePath  # link to the Die node from the editor or dynamically
@export var roll_increase := 1

func _ready():
	super._ready()
	hasDiscardEffect = true

func apply_discard_effect():
	var die = get_node_or_null(die_node_path)
	if die and die.has_method("changeTempMin"):
		die.changeTempMin(roll_increase)
		
func create_card(diePath: NodePath = '') -> Dictionary:
	die_node_path = diePath
	var titleString = "Soto Shuffle"
	roll_increase = 1
	var descString = "On Discard (Take Pitch) adds " + String.num_int64(roll_increase) + " to 1 dies minimum roll"
	var emptyDict:  Dictionary
	super.set_card_data(titleString, emptyDict, descString)
	return emptyDict
	
		
