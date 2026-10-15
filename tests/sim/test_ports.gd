extends GutTest

var def: BuildingDef


func before_each() -> void:
	def = BuildingDef.new()
	def.size = Vector2i(2, 1)
	var input := PortDef.new()
	input.cell = Vector2i(0, 0)
	input.side = PortDef.Side.DOWN
	def.inputs.append(input)
	var output := PortDef.new()
	output.cell = Vector2i(1, 0)
	output.side = PortDef.Side.RIGHT
	def.outputs.append(output)


func assert_ports(rotation: int, input_cell: Vector2i, input_side: int, output_cell: Vector2i, output_side: int) -> void:
	var building := BuildingState.new(def, Vector2i(5, 5), rotation)
	assert_eq(Ports.world_cell(building, def.inputs[0]), Vector2i(5, 5) + input_cell, "input cell at rotation %d" % rotation)
	assert_eq(Ports.world_side(building, def.inputs[0]), input_side, "input side at rotation %d" % rotation)
	assert_eq(Ports.world_cell(building, def.outputs[0]), Vector2i(5, 5) + output_cell, "output cell at rotation %d" % rotation)
	assert_eq(Ports.world_side(building, def.outputs[0]), output_side, "output side at rotation %d" % rotation)


func test_rotation_0() -> void:
	assert_ports(0, Vector2i(0, 0), PortDef.Side.DOWN, Vector2i(1, 0), PortDef.Side.RIGHT)


func test_rotation_1() -> void:
	assert_ports(1, Vector2i(0, 0), PortDef.Side.LEFT, Vector2i(0, 1), PortDef.Side.DOWN)


func test_rotation_2() -> void:
	assert_ports(2, Vector2i(1, 0), PortDef.Side.UP, Vector2i(0, 0), PortDef.Side.LEFT)


func test_rotation_3() -> void:
	assert_ports(3, Vector2i(0, 1), PortDef.Side.RIGHT, Vector2i(0, 0), PortDef.Side.UP)


func test_rotated_size_swaps_on_odd_turns() -> void:
	assert_eq(Ports.rotated_size(Vector2i(2, 1), 1), Vector2i(1, 2))
	assert_eq(Ports.rotated_size(Vector2i(2, 1), 2), Vector2i(2, 1))


func test_side_rotation_wraps_from_left_to_up() -> void:
	assert_eq(Ports.rotate_side(PortDef.Side.LEFT, 1), PortDef.Side.UP)


func test_covered_cells_follow_rotation() -> void:
	assert_eq(Ports.covered_cells(Vector2i(2, 1), Vector2i(3, 3), 1), [Vector2i(3, 3), Vector2i(3, 4)] as Array[Vector2i])


func test_side_toward_neighbor() -> void:
	assert_eq(Ports.side_toward(Vector2i(0, 0), Vector2i(-1, 0)), PortDef.Side.LEFT)
	assert_eq(Ports.side_toward(Vector2i(0, 0), Vector2i(0, 1)), PortDef.Side.DOWN)
