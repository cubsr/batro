extends BaseCard
class_name ShuffleCard

@export var die_node_path: NodePath  # link to the Die node from the editor or dynamically
@export var roll_increase := 0

func _ready():
	super._ready()
	hasDiscardEffect = true

func apply_discard_effect():
	var die = get_node_or_null(die_node_path)
	if die and die.has_method("adjust_roll_bounds"):
		die.adjust_roll_bounds(roll_increase)
		
func create_card():
	
		
