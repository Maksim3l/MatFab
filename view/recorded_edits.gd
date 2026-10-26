class_name RecordedEdits extends RefCounted

# Sim changes that make one undo step each in an EditHistory.


static func placement_of(building: BuildingState) -> Placement:
	return Placement.new(building.def.id, building.origin, building.rotation)


# Placements that do not fit are skipped, so a miner dragged across an ore patch fills only the ore.
# A conveyor replaced on the way counts as removed.
static func place_all(sim: Simulation, history: EditHistory, placements: Array[Placement]) -> void:
	var added: Array[Placement] = []
	var removed: Array[Placement] = []
	for placement in placements:
		var existing := sim.building_at(placement.origin)
		var replaced := existing != null and sim.replaces(sim.defs[placement.def_id], existing)
		var before := placement_of(existing) if replaced else null
		if sim.place(placement.def_id, placement.origin, placement.rotation):
			if before != null:
				forget_or_remove(before, added, removed)
			added.append(placement)
	history.record(added, removed)


static func remove_all(sim: Simulation, history: EditHistory, buildings: Array[BuildingState]) -> void:
	var removed: Array[Placement] = []
	for building in buildings:
		if sim.remove(building.origin):
			removed.append(placement_of(building))
	history.record([] as Array[Placement], removed)


# Every building under the cells, once each, the mothership excepted.
static func buildings_under(sim: Simulation, cells: Array[Vector2i]) -> Array[BuildingState]:
	var found: Array[BuildingState] = []
	for cell in cells:
		var building := sim.building_at(cell)
		if building != null and building.def.behavior != BuildingDef.Behavior.MOTHERSHIP and not found.has(building):
			found.append(building)
	return found


# A building the same gesture added and then replaced was never there before the gesture.
static func forget_or_remove(before: Placement, added: Array[Placement], removed: Array[Placement]) -> void:
	for i in added.size():
		if added[i].equals(before):
			added.remove_at(i)
			return
	removed.append(before)
