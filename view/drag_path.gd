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
