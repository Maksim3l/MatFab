class_name Ports extends RefCounted

# Indexed by PortDef.Side.
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]


static func rotated_size(size: Vector2i, quarter_turns: int) -> Vector2i:
	return size if posmod(quarter_turns, 2) == 0 else Vector2i(size.y, size.x)


# Rotates a cell inside a block of `size` clockwise; the result is inside the rotated size.
static func rotate_cell(cell: Vector2i, size: Vector2i, quarter_turns: int) -> Vector2i:
	var rotated := cell
	var current_size := size
	for turn in posmod(quarter_turns, 4):
		rotated = Vector2i(current_size.y - 1 - rotated.y, rotated.x)
		current_size = Vector2i(current_size.y, current_size.x)
	return rotated


static func rotate_side(side: int, quarter_turns: int) -> int:
	return posmod(side + quarter_turns, 4)


static func opposite_side(side: int) -> int:
	return posmod(side + 2, 4)


static func direction(side: int) -> Vector2i:
	return DIRECTIONS[side]


static func side_toward(from_cell: Vector2i, to_cell: Vector2i) -> int:
	return DIRECTIONS.find((to_cell - from_cell).sign())


static func covered_cells(size: Vector2i, origin: Vector2i, quarter_turns: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var rotated := rotated_size(size, quarter_turns)
	for y in rotated.y:
		for x in rotated.x:
			cells.append(origin + Vector2i(x, y))
	return cells


static func world_cell(building: BuildingState, port: PortDef) -> Vector2i:
	return building.origin + rotate_cell(port.cell, building.def.size, building.rotation)


static func world_side(building: BuildingState, port: PortDef) -> int:
	return rotate_side(port.side, building.rotation)
