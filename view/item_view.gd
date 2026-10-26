class_name ItemView extends Node2D

const RADIUS := 0.3
const FONT_SIZE := 26
const MIN_FONT_SIZE := 10
const TEXT_COLOR := Color.WHITE
const OUTLINE_COLOR := Color(0, 0, 0, 0.55)

var sim: Simulation
var clock: SimClock


func show_sim(simulation: Simulation, sim_clock: SimClock) -> void:
	sim = simulation
	clock = sim_clock


static func number_color(value: int) -> Color:
	return Color.from_hsv(fposmod(0.08 + value * 0.17, 1.0), 0.6, 0.78)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	for building in sim.buildings:
		match building.def.behavior:
			BuildingDef.Behavior.CONVEYOR:
				draw_conveyor_number(building)
			BuildingDef.Behavior.PROCESSOR:
				draw_processor_numbers(building)


func draw_conveyor_number(conveyor: BuildingState) -> void:
	if conveyor.inputs[0] == null:
		return
	var progress := ConveyorPath.progress(conveyor.timer, clock.fraction(), conveyor.duration_ticks())
	var local := ConveyorPath.point(ConveyorPath.input_side(sim, conveyor), conveyor.front_side(), progress)
	draw_number(Grid.cell_center(conveyor.origin) + local * Grid.CELL_SIZE, conveyor.inputs[0], 1.0)


# Numbers waiting in a processor's slots sit just inside the port they belong to.
func draw_processor_numbers(processor: BuildingState) -> void:
	for i in processor.def.outputs.size():
		if processor.outputs[i] != null:
			draw_number(port_point(processor, processor.def.outputs[i]), processor.outputs[i], 0.8)
	for i in processor.def.inputs.size():
		var port := processor.def.inputs[i]
		if port.source == PortDef.Source.NEIGHBOR and processor.inputs[i] != null:
			draw_number(port_point(processor, port), processor.inputs[i], 0.65)


func port_point(building: BuildingState, port: PortDef) -> Vector2:
	var center := Grid.cell_center(Ports.world_cell(building, port))
	return center + Vector2(Ports.direction(Ports.world_side(building, port))) * Grid.CELL_SIZE * 0.25


func draw_number(at: Vector2, value: int, scale_factor: float) -> void:
	var radius := RADIUS * Grid.CELL_SIZE * scale_factor
	draw_circle(at, radius + 2.0, OUTLINE_COLOR)
	draw_circle(at, radius, number_color(value))
	var digits_scale := 0.5 if value >= 1000 else 0.65 if value >= 100 else 1.0
	var font_size := int(FONT_SIZE * scale_factor * digits_scale)
	var width := radius * 2.0
	draw_string(ThemeDB.fallback_font, at + Vector2(-radius, font_size * 0.35), str(value), HORIZONTAL_ALIGNMENT_CENTER, width, font_size, TEXT_COLOR)
