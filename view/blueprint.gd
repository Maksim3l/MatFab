class_name Blueprint extends RefCounted

# Each part's origin is its offset from the blueprint's top-left cell.
var parts: Array[Placement] = []
# Footprint of each part in its own rotation, in the same order as `parts`.
var footprints: Array[Vector2i] = []
var size := Vector2i.ZERO


# Every building with a cell inside `rect`, the mothership excepted, relative to the top-left of them all.
static func capture(sim: Simulation, rect: Rect2i) -> Blueprint:
	var blueprint := Blueprint.new()
	var found: Array[BuildingState] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var building := sim.building_at(Vector2i(x, y))
			if building != null and building.def.behavior != BuildingDef.Behavior.MOTHERSHIP and not found.has(building):
				found.append(building)
	if found.is_empty():
		return blueprint
	var top_left := found[0].origin
	for building in found:
		top_left = top_left.min(building.origin)
	for building in found:
		blueprint.add_part(Placement.new(building.def.id, building.origin - top_left, building.rotation), building.size())
	return blueprint


func add_part(part: Placement, footprint: Vector2i) -> void:
	parts.append(part)
	footprints.append(footprint)
	size = size.max(part.origin + footprint)


func is_empty() -> bool:
	return parts.is_empty()


# The whole blueprint turned a quarter clockwise; every part turns with it.
func rotated_cw() -> Blueprint:
	var turned := Blueprint.new()
	for i in parts.size():
		var part := parts[i]
		var footprint := footprints[i]
		var offset := Vector2i(size.y - (part.origin.y + footprint.y), part.origin.x)
		turned.add_part(Placement.new(part.def_id, offset, posmod(part.rotation + 1, 4)), Vector2i(footprint.y, footprint.x))
	turned.size = Vector2i(size.y, size.x)
	return turned


func placements_at(origin: Vector2i) -> Array[Placement]:
	var placed: Array[Placement] = []
	for part in parts:
		placed.append(Placement.new(part.def_id, origin + part.origin, part.rotation))
	return placed
