extends GutTest

const UP := 0
const RIGHT := 1
const DOWN := 2
const LEFT := 3


func rotations_of(placements: Array[Placement]) -> Array[int]:
	var rotations: Array[int] = []
	for placement in placements:
		rotations.append(placement.rotation)
	return rotations


func test_cells_between_skips_no_cell_on_a_fast_drag() -> void:
	assert_eq(DragPath.cells_between(Vector2i(0, 0), Vector2i(3, 0)), [Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)] as Array[Vector2i])


func test_cells_between_steps_one_edge_at_a_time_on_a_diagonal() -> void:
	var cells := DragPath.cells_between(Vector2i(0, 0), Vector2i(2, 2))
	assert_eq(cells.size(), 4)
	var previous := Vector2i(0, 0)
	for cell in cells:
		assert_eq(absi(cell.x - previous.x) + absi(cell.y - previous.y), 1)
		previous = cell
	assert_eq(cells.back(), Vector2i(2, 2))


func test_each_conveyor_faces_the_next_cell() -> void:
	var cells: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	assert_eq(rotations_of(DragPath.conveyor_placements(&"conveyor", cells, UP, false)), [RIGHT, RIGHT, RIGHT] as Array[int])


func test_a_turn_makes_a_corner() -> void:
	var cells: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
	assert_eq(rotations_of(DragPath.conveyor_placements(&"conveyor", cells, UP, false)), [RIGHT, DOWN, DOWN, DOWN] as Array[int])


func test_a_single_cell_keeps_the_tool_rotation() -> void:
	var cells: Array[Vector2i] = [Vector2i(4, 4)]
	assert_eq(rotations_of(DragPath.conveyor_placements(&"conveyor", cells, LEFT, false)), [LEFT] as Array[int])
