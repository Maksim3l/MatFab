class_name ConveyorPath extends RefCounted

# A number on a conveyor travels from the middle of the edge it entered through, to the cell center,
# to the middle of the front edge. Points are in cell units, (0, 0) at the cell center.


static func edge_point(side: int) -> Vector2:
	return Vector2(Ports.direction(side)) * 0.5


static func point(input_side: int, front_side: int, progress: float) -> Vector2:
	if progress < 0.5:
		return edge_point(input_side).lerp(Vector2.ZERO, progress * 2.0)
	return Vector2.ZERO.lerp(edge_point(front_side), (progress - 0.5) * 2.0)


# How far along the path a number is, from its timer and the clock fraction toward the next step.
static func progress(timer: int, step_fraction: float, duration_ticks: int) -> float:
	return clampf((timer + step_fraction) / duration_ticks, 0.0, 1.0)


# The side a conveyor is drawn as fed from: its back, unless only a side neighbor hands numbers into it.
static func input_side(sim: Simulation, conveyor: BuildingState) -> int:
	var back := Ports.opposite_side(conveyor.front_side())
	if feeds(sim, conveyor.origin, back):
		return back
	for turn in [1, 3]:
		var side := Ports.rotate_side(conveyor.front_side(), turn)
		if feeds(sim, conveyor.origin, side):
			return side
	return back


# Whether the building across `side` of `cell` hands numbers into `cell`.
static func feeds(sim: Simulation, cell: Vector2i, side: int) -> bool:
	var neighbor_cell := cell + Ports.direction(side)
	var neighbor := sim.building_at(neighbor_cell)
	if neighbor == null:
		return false
	var toward_cell := Ports.opposite_side(side)
	if neighbor.def.behavior == BuildingDef.Behavior.CONVEYOR:
		return neighbor.front_side() == toward_cell
	for port in neighbor.def.outputs:
		if Ports.world_cell(neighbor, port) == neighbor_cell and Ports.world_side(neighbor, port) == toward_cell:
			return true
	return false
