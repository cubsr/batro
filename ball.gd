extends Node2D

@onready var sprite = $ballImage

func start_animation(start_pos: Vector2, target_pos: Vector2):
	position = start_pos
	scale = Vector2.ZERO
	modulate.a = 0.0

	var tw = create_tween()
	tw.tween_property(self, "position", target_pos, 0.5)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
