class_name GroundView extends Node2D

const GROUND_COLOR := Color("1d2430")
const GRID_COLOR := Color(1, 1, 1, 0.05)
const ORE_TEXT_COLOR := Color(1, 1, 1, 0.85)
const ORE_FONT_SIZE := 30

var sim: Simulation


func show_sim(simulation: Simulation) -> void:
	sim = simulation
	queue_redraw()


static func ore_color(value: int) -> Color:
	return Color.from_hsv(fposmod(0.08 + value * 0.17, 1.0), 0.45, 0.42)


func _draw() -> void:
	if sim == null:
		return
	var bounds := Grid.cells_rect(sim.bounds.position, sim.bounds.size)
	draw_rect(bounds, GROUND_COLOR)
	for x in range(sim.bounds.position.x, sim.bounds.end.x + 1):
		draw_line(Vector2(x * Grid.CELL_SIZE, bounds.position.y), Vector2(x * Grid.CELL_SIZE, bounds.end.y), GRID_COLOR)
	for y in range(sim.bounds.position.y, sim.bounds.end.y + 1):
		draw_line(Vector2(bounds.position.x, y * Grid.CELL_SIZE), Vector2(bounds.end.x, y * Grid.CELL_SIZE), GRID_COLOR)
	for cell in sim.ore:
		var rect := Grid.cells_rect(cell, Vector2i.ONE).grow(-2)
		draw_rect(rect, ore_color(sim.ore[cell]))
		draw_centered_text(rect, str(sim.ore[cell]), ORE_FONT_SIZE, ORE_TEXT_COLOR)


func draw_centered_text(rect: Rect2, text: String, font_size: int, color: Color) -> void:
	var baseline := rect.position + Vector2(0, rect.size.y * 0.5 + font_size * 0.35)
	draw_string(ThemeDB.fallback_font, baseline, text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, color)
