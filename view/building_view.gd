class_name BuildingView extends Node2D

const FILL_COLOR := Color("3c4a63")
const BORDER_COLOR := Color("8fa3c7")
const SYMBOL_COLOR := Color.WHITE
const SYMBOL_FONT_SIZE := 34

const BELT_STRAIGHT := preload("res://assets/real/belt_gor_dol.png")
const BELT_TURN_RIGHT := preload("res://assets/real/belt_zavoj_desno.png")
const BELT_TURN_LEFT := preload("res://assets/real/belt_zavoj_levo.png")
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
	if def.sprite != null:
		draw_sprite(def, Grid.cells_rect(origin, size).get_center(), rotation, Color(tint, alpha))
	else:
		var rect := Grid.cells_rect(origin, size).grow(-4)
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


func draw_sprite(def: BuildingDef, center: Vector2, rotation: int, color: Color) -> void:
	var footprint := Vector2(def.size * Grid.CELL_SIZE)
	if def.sprite_turns % 2 == 1:
		footprint = Vector2(footprint.y, footprint.x)
	var texture_size := def.sprite.get_size()
	var fit := minf(footprint.x / texture_size.x, footprint.y / texture_size.y)
	draw_turned_texture(def.sprite, center, texture_size * fit, rotation + def.sprite_turns, color)


func draw_turned_texture(texture: Texture2D, center: Vector2, size: Vector2, quarter_turns: int, color: Color) -> void:
	draw_set_transform(center, quarter_turns * PI / 2.0)
	draw_texture_rect(texture, Rect2(-size / 2.0, size), false, color)
	draw_set_transform(Vector2.ZERO)


func draw_conveyor(cell: Vector2i, input_side: int, front_side: int, alpha: float, tint := Color.WHITE) -> void:
	var texture := BELT_STRAIGHT
	var art_front := PortDef.Side.UP
	match posmod(input_side - front_side, 4):
		1:
			texture = BELT_TURN_RIGHT
			art_front = PortDef.Side.RIGHT
		3:
			texture = BELT_TURN_LEFT
			art_front = PortDef.Side.LEFT
	var size := Vector2.ONE * Grid.CELL_SIZE
	draw_turned_texture(texture, Grid.cell_center(cell), size, front_side - art_front, Color(tint, alpha))
