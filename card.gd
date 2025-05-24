extends Control
class_name BaseCard

signal show_popup(title: String, description: String, position: Vector2)
signal hide_popup()

@onready var titleLable: Label = $Title
@onready var desc: Label = $Description
@onready var highlight_overlay: ColorRect = $HighlightOverlay
@onready var swing_grid = $SwingGrid


var zones: Array = []
var hovered: Tween
var hovered_scale = Vector2(1.1, 1.1)
var normal_scale = Vector2(1, 1)
var lift_offset = Vector2(0, -20)
var original_position = Vector2()
var is_selected = false
signal card_selected()


var title := ""
var description := ""

func _ready():
	hovered = get_tree().create_tween()
	original_position = position
	_init_zones()
	update_ui()


func set_card_data(inputTitle: String, inputDesc: String, zoneWithRarity: Dictionary) -> void:
	title = inputTitle
	description = inputDesc
	if !zoneWithRarity.is_empty():
		highlight_zones(zoneWithRarity)
	update_ui()
	
func apply_zone_colors(zoneWithRarity: Dictionary) -> void:
	highlight_zones(zoneWithRarity)
		
func update_ui():
	if titleLable:
		titleLable.text = title
	if desc and description != "":
		desc.text = description
		desc.visible = true

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
	emit_signal("card_selected")

func deselect_card():
	is_selected = false
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.2)
	emit_signal("card_selected")
	
func _init_zones():
	for i in range(9):
		var zone = swing_grid.get_child(i)
		zones.append(zone)
		zone.color = Color("gray")
		
func highlight_zones(zoneWithRarity: Dictionary):
	var hitTypeColors := {
	"Single": Color("#1EFF00"),
	"Double": Color("#0070FF"),
	"Triple": Color("#A335EE"),
	"Homer": Color("#FF8000"),
	"Negative": Color("#FF3B3B")
	}
	for zoneIndex in zoneWithRarity.keys():
		var rarity = zoneWithRarity[zoneIndex]
		var color = hitTypeColors.get(rarity, Color.WHITE)
		var zone = $SwingGrid.get_child(zoneIndex)
		zone.color = color
		
func _get_adjacent_indexes(index: int) -> Array:
	var adjacent = []
	var row = index / 3
	var col = index % 3
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var r = row + dy
			var c = col + dx
			if r >= 0 and r < 3 and c >= 0 and c < 3:
				adjacent.append(r * 3 + c)

	return adjacent
