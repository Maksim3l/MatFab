extends GutTest


func test_world_to_cell_floors_negative_positions() -> void:
	assert_eq(Grid.world_to_cell(Vector2(-1, -1)), Vector2i(-1, -1))
	assert_eq(Grid.world_to_cell(Vector2(Grid.CELL_SIZE * 2 + 1, 5)), Vector2i(2, 0))


func test_cell_center_is_inside_the_cell() -> void:
	assert_eq(Grid.world_to_cell(Grid.cell_center(Vector2i(-3, 4))), Vector2i(-3, 4))
