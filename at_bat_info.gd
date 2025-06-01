extends Control

# Max counts
const MAX_STRIKES = 3
const MAX_BALLS = 4
const MAX_OUTS = 3

const STRIKE_COLOR_ON = Color(1, 1, 0) # Yellow
const BALL_COLOR_ON = Color(0, 1, 0) # Green
const OUT_COLOR_ON = Color(1, 0, 0)  # Red

const LIGHT_OFF_MODULATE = Color(0.2, 0.2, 0.2)

# Store references to the lights
var strike_lights = []
var ball_lights = []
var out_lights = []

func _ready():
	setup()
	
func setup():
	var strike_container = $StrikeGroup
	var ball_container = $BallGroup
	var out_container = $OutsGroup
	print("setup ", strike_container, " ", ball_container, " ", out_container)
	if strike_container and ball_container and out_container:
		var tempArray = []
		for child in strike_container.get_children():
			if child is TextureRect:
				tempArray.append(child)
		strike_lights = sortChildArrayByX(tempArray)
		tempArray = []
		for child in ball_container.get_children():
			if child is TextureRect:
				tempArray.append(child)
		ball_lights = sortChildArrayByX(tempArray)
		tempArray = []
		for child in out_container.get_children():
			if child is TextureRect:
				tempArray.append(child)
		out_lights = sortChildArrayByX(tempArray)
	update_lights(0, 0, 0)
	
func sortChildArrayByX(items: Array) -> Array:
	var tempArray = []
	while not items.is_empty():
		var smallestX = getSmallestX(items)
		tempArray.append(smallestX)
		var index = items.find(smallestX)
		if index > -1:
			items.remove_at(index)
		else:
			items.remove_at(0)
	return tempArray
	
func getSmallestX(items: Array) -> TextureRect:
	var smallestX = items[0].position.x
	var texture = items[0]
	for item in items:
		if item.position.x < smallestX:
			texture = item
			smallestX = item.position.x
	return texture

func update_lights(outs: int, balls: int, strikes: int) -> void:
	# Update strikes
	if not strike_lights.is_empty():
		for i in range(MAX_STRIKES):
			if i < strikes:
				strike_lights[i].modulate = STRIKE_COLOR_ON
			else:
				strike_lights[i].modulate = LIGHT_OFF_MODULATE

	# Update balls
	if not ball_lights.is_empty():
		for i in range(MAX_BALLS):
			if i < balls:
				ball_lights[i].modulate = BALL_COLOR_ON
			else:
				ball_lights[i].modulate = LIGHT_OFF_MODULATE

	# Update outs
	if not out_lights.is_empty():
		for i in range(MAX_OUTS):
			if i < outs:
				out_lights[i].modulate = OUT_COLOR_ON
			else:
				out_lights[i].modulate = LIGHT_OFF_MODULATE

func add_strike() -> void:
	var current = getCountFromLights(strike_lights)
	print("Strike count ", current)
	if current < MAX_STRIKES:
		print("modulating ", strike_lights[current])
		strike_lights[current].modulate = STRIKE_COLOR_ON

func add_ball() -> void:
	var current = getCountFromLights(ball_lights)
	if current < MAX_BALLS:
		ball_lights[current].modulate = STRIKE_COLOR_ON

func add_out() -> void:
	var current = getCountFromLights(out_lights)
	if current < MAX_OUTS:
		out_lights[current].modulate = OUT_COLOR_ON
				
func getCountFromLights(light_array: Array) -> int:
	var count = 0
	for light in light_array:
		if light.modulate != LIGHT_OFF_MODULATE:
			count += 1
	return count
	
func getOutsLights() -> int:
	var count = 0
	for light in out_lights:
		if light.modulate != LIGHT_OFF_MODULATE:
			count += 1
	return count
	
func getStrikesLights() -> int:
	var count = 0
	for light in strike_lights:
		if light.modulate != LIGHT_OFF_MODULATE:
			count += 1
	return count
	
func getBallsLights() -> int:
	var count = 0
	for light in ball_lights:
		if light.modulate != LIGHT_OFF_MODULATE:
			count += 1
	return count
