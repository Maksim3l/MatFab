class_name DragPath extends RefCounted


# Cells a finger passes moving from `from` to `to`, each sharing an edge with the one before,
# so a fast drag skips no cell. `from` is left out, `to` is included.
static func cells_between(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var current := from
	while current != to:
		var remaining := to - current
		if absi(remaining.x) >= absi(remaining.y):
			current.x += signi(remaining.x)
		else:
			current.y += signi(remaining.y)
		cells.append(current)
	return cells


# One conveyor per cell, each facing the next cell, so a turn in the drag makes a corner.
# The last one keeps the direction of the last step, and a single cell keeps `single_rotation`.
# Flipped, each faces the previous cell instead.
static func conveyor_placements(def_id: StringName, cells: Array[Vector2i], single_rotation: int, flipped: bool) -> Array[Placement]:
	var placements: Array[Placement] = []
	if cells.size() == 1:
		placements.append(Placement.new(def_id, cells[0], single_rotation))
		return placements
	var ordered := cells.duplicate()
	if flipped:
		ordered.reverse()
	for i in ordered.size():
		var side := Ports.side_toward(ordered[i], ordered[i + 1]) if i < ordered.size() - 1 else Ports.side_toward(ordered[i - 1], ordered[i])
		placements.append(Placement.new(def_id, ordered[i], side))
	if flipped:
		placements.reverse()
	return placements


# Keeps a drag on the axis of its first step: every cell moves onto the line through the first cell.
static func lock_to_axis(cells: Array[Vector2i]) -> Array[Vector2i]:
	if cells.size() < 2:
		return cells.duplicate()
	var horizontal := cells[1].y == cells[0].y
	var locked: Array[Vector2i] = [cells[0]]
	for cell in cells.slice(1):
		var on_axis := Vector2i(cell.x, cells[0].y) if horizontal else Vector2i(cells[0].x, cell.y)
		if on_axis != locked.back():
			locked.append_array(cells_between(locked.back(), on_axis))
	return locked


# One origin per footprint step along the drag: a cell becomes an origin unless the block placed there
# would overlap one already taken, so a 2x1 block dragged sideways lands on every second cell.
static func stepped_origins(origins: Array[Vector2i], footprint: Vector2i) -> Array[Vector2i]:
	var taken: Array[Vector2i] = []
	for origin in origins:
		var rect := Rect2i(origin, footprint)
		var overlaps := false
		for other in taken:
			if rect.intersects(Rect2i(other, footprint)):
				overlaps = true
				break
		if not overlaps:
			taken.append(origin)
	return taken
