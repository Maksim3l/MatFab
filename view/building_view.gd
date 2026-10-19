class_name BuildingView extends Node2D

const FILL_COLOR := Color("3c4a63")
const BORDER_COLOR := Color("8fa3c7")
const SYMBOL_COLOR := Color.WHITE
const SYMBOL_FONT_SIZE := 34
const BELT_COLOR := Color("4a5160")
const BELT_EDGE_COLOR := Color("2a2f38")
const ARROW_COLOR := Color("c9d3e3")
const BELT_WIDTH := 0.62
const PORT_COLOR := Color("f0c35a")

var sim: Simulation


func show_sim(simulation: Simulation) -> void:
	sim = simulation


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	for building in sim.buildings:
		if building.def.behavior == BuildingDef.Behavior.CONVEYOR:
			draw_conveyor(building.origin, ConveyorPath.input_side(sim, building), building.front_side(), 1.0)
		else:
			draw_placeholder(building.def, building.origin, building.rotation, 1.0)


func draw_placeholder(def: BuildingDef, origin: Vector2i, rotation: int, alpha: float, tint := Color.WHITE) -> void:
	var size := Ports.rotated_size(def.size, rotation)
	var rect := Grid.cells_rect(origin, size).grow(-4)
	if def.sprite != null:
		draw_texture_rect(def.sprite, rect, false, Color(tint, alpha))
		return
	draw_rect(rect, FILL_COLOR * tint * Color(1, 1, 1, alpha))
	draw_rect(rect, BORDER_COLOR * tint * Color(1, 1, 1, alpha), false, 3.0)
	var font_size := SYMBOL_FONT_SIZE * mini(size.x, size.y)
	var baseline := rect.position + Vector2(0, rect.size.y * 0.5 + font_size * 0.35)
	draw_string(ThemeDB.fallback_font, baseline, def.symbol, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, Color(SYMBOL_COLOR, alpha))
	var probe := BuildingState.new(def, origin, rotation)
	for port in def.inputs:
		if port.source == PortDef.Source.NEIGHBOR:
			draw_port_mark(Ports.world_cell(probe, port), Ports.world_side(probe, port), false, alpha)
	for port in def.outputs:
		draw_port_mark(Ports.world_cell(probe, port), Ports.world_side(probe, port), true, alpha)


# A small triangle on the port edge, pointing out of the building for outputs and into it for inputs.
func draw_port_mark(cell: Vector2i, side: int, outward: bool, alpha: float) -> void:
	var center := Grid.cell_center(cell)
	var direction := Vector2(Ports.direction(side))
	var edge := center + direction * Grid.CELL_SIZE * 0.5
	var across := direction.orthogonal() * Grid.CELL_SIZE * 0.14
	var depth := direction * Grid.CELL_SIZE * 0.16 * (1.0 if outward else -1.0)
	var base := edge - depth * 0.5
	draw_colored_polygon(PackedVector2Array([base + across, base - across, base + depth]), Color(PORT_COLOR, alpha))


func draw_conveyor(cell: Vector2i, input_side: int, front_side: int, alpha: float, tint := Color.WHITE) -> void:
	var center := Grid.cell_center(cell)
	var path := PackedVector2Array([
		center + ConveyorPath.edge_point(input_side) * Grid.CELL_SIZE,
		center,
		center + ConveyorPath.edge_point(front_side) * Grid.CELL_SIZE,
	])
	draw_polyline(path, BELT_EDGE_COLOR * tint * Color(1, 1, 1, alpha), Grid.CELL_SIZE * (BELT_WIDTH + 0.08), false)
	draw_polyline(path, BELT_COLOR * tint * Color(1, 1, 1, alpha), Grid.CELL_SIZE * BELT_WIDTH, false)
	var direction := Vector2(Ports.direction(front_side))
	var across := direction.orthogonal() * Grid.CELL_SIZE * 0.16
	var tip := center + direction * Grid.CELL_SIZE * 0.3
	var back := tip - direction * Grid.CELL_SIZE * 0.2
	draw_polyline(PackedVector2Array([back + across, tip, back - across]), Color(ARROW_COLOR, alpha * 0.8), 4.0)
