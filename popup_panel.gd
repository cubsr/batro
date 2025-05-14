extends Panel
@onready var title_label = $VBoxContainer/Title
@onready var description_label = $VBoxContainer/Description

func show_info(title: String, description: String, position: Vector2):
	title_label.text = title
	description_label.text = description
	self.position = position
	show()

func hide_info():
	hide()
