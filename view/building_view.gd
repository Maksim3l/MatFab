class_name BuildingView extends Node2D

const FILL_COLOR := Color("3c4a63")
const BORDER_COLOR := Color("8fa3c7")
const SYMBOL_COLOR := Color.WHITE
const SYMBOL_FONT_SIZE := 34

var sim: Simulation


func show_sim(simulation: Simulation) -> void:
	sim = simulation


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	for building in sim.buildings:
		draw_placeholder(building)


func draw_placeholder(building: BuildingState) -> void:
	var rect := Grid.cells_rect(building.origin, building.size()).grow(-4)
	if building.def.sprite != null:
		draw_texture_rect(building.def.sprite, rect, false)
		return
	draw_rect(rect, FILL_COLOR)
	draw_rect(rect, BORDER_COLOR, false, 3.0)
	var font_size := SYMBOL_FONT_SIZE * mini(building.size().x, building.size().y)
	var baseline := rect.position + Vector2(0, rect.size.y * 0.5 + font_size * 0.35)
	draw_string(ThemeDB.fallback_font, baseline, building.def.symbol, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, SYMBOL_COLOR)
