extends BaseCard
class_name PowerCard
var zonesHits: Dictionary = {}

func _ready():
	super._ready()

func create_card() -> Dictionary:
	var zonesWithHitTypes := {}
	var titleString = "Power Swing"
	var center = randi() % 9
	zonesWithHitTypes[center] = "Double"
	var neighbors = super._get_adjacent_indexes(center)
	neighbors.shuffle()
	
	for i in range(1):
		if neighbors.size() > i:
			zonesWithHitTypes[neighbors[i]] = "Single"
	super.set_card_data(titleString, zonesWithHitTypes)
	zonesHits = zonesWithHitTypes
	return zonesWithHitTypes
	
func create_card_from_values(zonesWithHitTypes: Dictionary) -> void:
	var titleString = "Power Swing"
	zonesHits = zonesWithHitTypes
	super.set_card_data(titleString, zonesWithHitTypes)
