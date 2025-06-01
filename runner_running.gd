extends Node2D

var running_sprite
var standing_sprite

func _ready():
	running_sprite = $Running
	standing_sprite = $Standing
	if running_sprite and standing_sprite:
		self.hide_runner()

func show_running():
	running_sprite.visible = true
	standing_sprite.visible = false

func show_standing():
	running_sprite.visible = false
	standing_sprite.visible = true

func hide_runner():
	running_sprite.visible = false
	standing_sprite.visible = false
	
func isFreeRunner():
	if running_sprite.visible == false and standing_sprite.visible == false:
		return true;
	return false
