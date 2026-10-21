class_name Pipette extends RefCounted

const KEEP_ROTATION := -1


# What a long press picks up: a building's def and rotation, or on bare ore the first buildable def with
# an ORE port, which keeps its own last rotation (KEEP_ROTATION). Null on empty ground and on blocks the level does not offer.
static func pick(sim: Simulation, cell: Vector2i, buildable: Array[BuildingDef]) -> Placement:
	var building := sim.building_at(cell)
	if building != null:
		if buildable.has(building.def):
			return Placement.new(building.def.id, building.origin, building.rotation)
		return null
	if sim.ore.has(cell):
		for def in buildable:
			for port in def.inputs:
				if port.source == PortDef.Source.ORE:
					return Placement.new(def.id, cell, KEEP_ROTATION)
	return null
