class_name Simulation extends RefCounted

const TICKS_PER_SECOND := 20
const MOTHERSHIP_ID := &"mothership"

var defs: Dictionary[StringName, BuildingDef]
var bounds: Rect2i
var cells: Dictionary[Vector2i, BuildingState] = {}
var ore: Dictionary[Vector2i, int] = {}
# Placement order; step() ticks in this order.
var buildings: Array[BuildingState] = []
var operations := Operations.new()
var behaviors: Dictionary[int, Behavior] = {}
var tracker: GoalTracker
var stepping := false
# Buildings already ticked in the running step.
var ticked: Dictionary[BuildingState, bool] = {}


func _init(building_defs: Dictionary[StringName, BuildingDef], map_bounds: Rect2i) -> void:
	defs = building_defs
	bounds = map_bounds
	behaviors[BuildingDef.Behavior.PROCESSOR] = ProcessorBehavior.new(self)
	behaviors[BuildingDef.Behavior.MOTHERSHIP] = MothershipBehavior.new(self)
	behaviors[BuildingDef.Behavior.CONVEYOR] = ConveyorBehavior.new(self)


# Every cell in level data is relative to the mothership, which sits at (0, 0).
static func from_level(level: LevelDef, building_defs: Dictionary[StringName, BuildingDef]) -> Simulation:
	var sim := Simulation.new(building_defs, Rect2i(-level.map_size / 2, level.map_size))
	for patch in level.ore_patches:
		for y in patch.size.y:
			for x in patch.size.x:
				sim.ore[patch.cell + Vector2i(x, y)] = patch.value
	sim.place(MOTHERSHIP_ID, Vector2i.ZERO, 0)
	sim.tracker = GoalTracker.new(level.goals)
	return sim


static func ticks_for(seconds: float) -> int:
	return maxi(1, roundi(seconds * TICKS_PER_SECOND))


func step() -> void:
	stepping = true
	for building in buildings.duplicate():
		var behavior: Behavior = behaviors.get(building.def.behavior)
		if behavior != null:
			behavior.tick(building)
		ticked[building] = true
	ticked.clear()
	stepping = false


# Timer for a number handed over now. A building that still ticks later in this step starts one lower,
# so a number spends the same number of steps on it whichever order the buildings were placed in.
func arrival_timer(building: BuildingState) -> int:
	return -1 if stepping and not ticked.has(building) else 0


# The only transfer path: hands `number` from `cell` across `side` to the building there.
func offer(cell: Vector2i, side: int, number: int) -> bool:
	var target_cell := cell + Ports.direction(side)
	var target: BuildingState = cells.get(target_cell)
	if target == null:
		return false
	var behavior: Behavior = behaviors.get(target.def.behavior)
	return behavior != null and behavior.accept(target, target_cell, Ports.opposite_side(side), number)


func building_at(cell: Vector2i) -> BuildingState:
	return cells.get(cell)


func can_place(def_id: StringName, origin: Vector2i, rotation: int) -> bool:
	var def: BuildingDef = defs.get(def_id)
	if def == null:
		return false
	for cell in Ports.covered_cells(def.size, origin, rotation):
		if not bounds.has_point(cell):
			return false
		var existing: BuildingState = cells.get(cell)
		if existing != null and not replaces(def, existing):
			return false
	var probe := BuildingState.new(def, origin, rotation)
	for port in def.inputs:
		if port.source == PortDef.Source.ORE and not ore.has(Ports.world_cell(probe, port)):
			return false
	return true


# A conveyor placed on a conveyor replaces it and keeps its number, so redrawing a line re-routes it.
func replaces(def: BuildingDef, existing: BuildingState) -> bool:
	return def.behavior == BuildingDef.Behavior.CONVEYOR and existing.def.behavior == BuildingDef.Behavior.CONVEYOR


func place(def_id: StringName, origin: Vector2i, rotation: int) -> bool:
	if not can_place(def_id, origin, rotation):
		return false
	var building := BuildingState.new(defs[def_id], origin, rotation)
	var replaced: BuildingState = cells.get(origin)
	if replaced != null:
		building.inputs = replaced.inputs.duplicate()
		building.timer = replaced.timer
		detach(replaced)
	attach(building)
	return true


func remove(cell: Vector2i) -> bool:
	var building: BuildingState = cells.get(cell)
	if building == null or building.def.behavior == BuildingDef.Behavior.MOTHERSHIP:
		return false
	detach(building)
	return true


func attach(building: BuildingState) -> void:
	buildings.append(building)
	for cell in building.covered_cells():
		cells[cell] = building


func detach(building: BuildingState) -> void:
	buildings.erase(building)
	for cell in building.covered_cells():
		cells.erase(cell)
