extends Control

@onready var label = $Number
@onready var tick_sound = $TickSound

var roll_time := 1.0  # total roll duration in seconds
var final_value := 0
var rolling := false
var _roll_timer := 0.0
var highestRoll := 6
var lowestRoll := 0
var tempHighRollAddition := 0
var tempLowRollAddition := 0
var tick_timer := 0.0
var tick_interval := 0.05

func _process(delta):
	if rolling:
		_roll_timer += delta
		tick_timer += delta

		if _roll_timer >= roll_time:
			rolling = false
			label.text = str(final_value)
		elif tick_timer >= tick_interval:
			tick_timer = 0.0
			var temp_value = randi_range(lowestRoll + tempLowRollAddition, highestRoll + tempHighRollAddition)
			label.text = str(temp_value)
			tick_interval = lerp(0.05, 0.25, _roll_timer / roll_time)
			bounce_number()
			play_tick_sound()

func roll(to_value: int, minValue: int = 0, maxValue: int = 6, duration: float = 1.0):
	final_value = to_value
	roll_time = duration
	lowestRoll = minValue
	highestRoll = maxValue
	_roll_timer = 0.0
	tick_timer = 0.0
	rolling = true

func bounce_number():
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1, 1), 0.1)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func play_tick_sound():
	if tick_sound.playing:
		tick_sound.stop()
	tick_sound.play()
	
func changeTempMin(amount: int):
	tempLowRollAddition += amount
	
func changeTempMax(amount: int):
	tempHighRollAddition += amount
	
func changePermMin(amount: int):
	lowestRoll += amount
	
func changePermMax(amount: int):
	highestRoll += amount	
