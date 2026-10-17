class_name Grid extends RefCounted

const CELL_SIZE := 64


static func cell_origin(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE)


static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_SIZE) + Vector2.ONE * CELL_SIZE * 0.5


static func world_to_cell(world: Vector2) -> Vector2i:
	return Vector2i((world / CELL_SIZE).floor())


static func cells_rect(origin: Vector2i, size: Vector2i) -> Rect2:
	return Rect2(cell_origin(origin), Vector2(size * CELL_SIZE))
