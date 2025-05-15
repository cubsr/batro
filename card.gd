extends Control
class_name BaseCard

signal show_popup(title: String, description: String, position: Vector2)
signal hide_popup()

@onready var titleLable: Label = $TextBox/Title
@onready var desc: Label = $TextBox/Description
@onready var highlight_overlay: ColorRect = $HighlightOverlay


var hovered: Tween
var hovered_scale = Vector2(1.1, 1.1)
var normal_scale = Vector2(1, 1)
var lift_offset = Vector2(0, -20)
var original_position = Vector2()
var is_selected = false


var title := ""
var description := ""
var hitChance = 50
var homerChance = 10

func _ready():
	hovered = get_tree().create_tween()
	original_position = position
	update_ui()

func set_card_data(inputTitle: String, inputDesc: String, inputHit: int, inputHomer: int) -> void:
	title = inputTitle
	description = inputDesc
	hitChance = inputHit
	homerChance = inputHomer
	update_ui()
		
func update_ui():
	if titleLable and desc:
		titleLable.text = title
		desc.text = description

func _on_mouse_entered():
	move_to_front()
	hovered.kill()
	hovered = get_tree().create_tween()
	hovered.tween_property(self, "scale", hovered_scale, 0.15)
	emit_signal("show_popup", titleLable.text, desc.text, get_screen_position() + Vector2(0, -100))

func _on_mouse_exited():
	hovered.kill()
	hovered = get_tree().create_tween()
	hovered.tween_property(self, "scale", normal_scale, 0.15)
	emit_signal("hide_popup")

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_selected:
			deselect_card()
		else:
			select_card()

func select_card():
	is_selected = true
	var target_position = position + Vector2(0, -30)
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.2)
	emit_signal("hide_popup")

func deselect_card():
	is_selected = false
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.2)
