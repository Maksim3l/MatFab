class_name MenuBelt extends Control

const BELT := preload("res://assets/real/belt_levo_desno.png")
const MINER := preload("res://assets/real/rudar.png")
const PIXEL_SCALE := 3.0
const SPEED := 90.0
const SPAWN_SECONDS := 1.4
const NUMBER_RADIUS := 30.0
const NUMBER_FONT_SIZE := 36
const NUMBER_COLOR := Color("f5d161")
const DIGIT_COLOR := Color("21262f")
const HOP_SECONDS := 0.45
const HOP_HEIGHT := 70.0

var _scroll := 0.0
var _spawn_timer := 0.0
# Each number on the belt: {x, value, hop}; hop counts down from HOP_SECONDS after a tap.
var _numbers: Array[Dictionary] = []


func _process(delta: float) -> void:
	var tile := _tile_size()
	_scroll = fmod(_scroll + SPEED * delta, tile)
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = SPAWN_SECONDS
		_numbers.append({x = MINER.get_width() * PIXEL_SCALE, value = randi_range(1, 9), hop = 0.0})
	for number in _numbers:
		number.x += SPEED * delta
		number.hop = maxf(number.hop - delta, 0.0)
	_numbers = _numbers.filter(func(number: Dictionary) -> bool: return number.x < size.x + NUMBER_RADIUS)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var touch := event as InputEventScreenTouch
	if touch == null or not touch.pressed:
		return
	for number in _numbers:
		if touch.position.distance_to(_number_center(number)) < NUMBER_RADIUS * 1.5:
			number.value += 1
			number.hop = HOP_SECONDS
			accept_event()
			return


func _draw() -> void:
	var tile := _tile_size()
	var belt_top := size.y - tile
	var x := _scroll - tile
	while x < size.x:
		draw_texture_rect(BELT, Rect2(x, belt_top, tile, tile), false)
		x += tile
	var miner_size := Vector2(MINER.get_size()) * PIXEL_SCALE
	draw_texture_rect(MINER, Rect2(Vector2(0, size.y - miner_size.y), miner_size), false)
	var font := get_theme_default_font()
	for number in _numbers:
		var center := _number_center(number)
		draw_circle(center, NUMBER_RADIUS, NUMBER_COLOR)
		var baseline := center.y + (font.get_ascent(NUMBER_FONT_SIZE) - font.get_descent(NUMBER_FONT_SIZE)) / 2.0
		draw_string(font, Vector2(center.x - NUMBER_RADIUS, baseline), str(number.value),
				HORIZONTAL_ALIGNMENT_CENTER, NUMBER_RADIUS * 2.0, NUMBER_FONT_SIZE, DIGIT_COLOR)


func _number_center(number: Dictionary) -> Vector2:
	var hop_offset := HOP_HEIGHT * sin(PI * number.hop / HOP_SECONDS)
	return Vector2(number.x, size.y - _tile_size() / 2.0 - hop_offset)


func _tile_size() -> float:
	return BELT.get_width() * PIXEL_SCALE
