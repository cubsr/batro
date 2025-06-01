extends VBoxContainer

var score = 0
var target_score = 15

var score_label
var target_label

func _ready():
	score_label = $HBoxContainer/Panel2/Number
	target_label = $HBoxContainer2/Panel2/Number
	if score_label and target_label:
		update_score_display()

func update_score_display():
	score_label.text = str(score)
	target_label.text = str(target_score)

func add_score(amount: int = 1):
	score += amount
	update_score_display()

func set_target_score(new_target: int):
	target_score = new_target
	update_score_display()
