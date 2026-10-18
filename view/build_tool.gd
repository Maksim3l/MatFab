class_name BuildTool extends Node

signal state_changed

var sim: Simulation
var buildable: Array[BuildingDef] = []
var tool_def: BuildingDef
# Each def keeps the rotation it was last placed with.
var rotations: Dictionary[StringName, int] = {}
var gesture_active := false
var drag_cells: Array[Vector2i] = []
var ghosts: Array[Placement] = []


func show_sim(simulation: Simulation, buildable_defs: Array[BuildingDef]) -> void:
	sim = simulation
	buildable = buildable_defs
	drop_tool()


func has_tool() -> bool:
	return tool_def != null


func select_def(def: BuildingDef) -> void:
	cancel_gesture()
	tool_def = def
	state_changed.emit()


func drop_tool() -> void:
	cancel_gesture()
	tool_def = null
	state_changed.emit()


# Slots count from 1, as on the toolbar; selecting the active slot drops the tool.
func select_slot(slot: int) -> void:
	if slot < 1 or slot > buildable.size():
		return
	var def := buildable[slot - 1]
	if tool_def == def:
		drop_tool()
	else:
		select_def(def)


func tool_rotation() -> int:
	return rotations.get(tool_def.id, 0)


func is_conveyor_tool() -> bool:
	return has_tool() and tool_def.behavior == BuildingDef.Behavior.CONVEYOR


func press(cell: Vector2i) -> void:
	if not has_tool():
		return
	gesture_active = true
	drag_cells = [cell]
	refresh_ghosts()


func drag_to(cell: Vector2i) -> void:
	if not gesture_active or cell == drag_cells.back():
		return
	drag_cells.append_array(DragPath.cells_between(drag_cells.back(), cell))
	refresh_ghosts()


func release() -> void:
	if not gesture_active:
		return
	commit(ghosts)
	if ghosts.size() > 0:
		rotations[tool_def.id] = ghosts.back().rotation
	cancel_gesture()
	if not tool_def.keep_selected:
		drop_tool()


func cancel_gesture() -> void:
	gesture_active = false
	drag_cells.clear()
	ghosts.clear()


func refresh_ghosts() -> void:
	ghosts = placements_for(drag_cells)


func placements_for(cells: Array[Vector2i]) -> Array[Placement]:
	if is_conveyor_tool():
		return DragPath.conveyor_placements(tool_def.id, cells, tool_rotation(), false)
	var single: Array[Placement] = [Placement.new(tool_def.id, origin_under(cells[0], tool_rotation()), tool_rotation())]
	return single


# Origin that puts the block's middle cell under the finger.
func origin_under(cell: Vector2i, rotation: int) -> Vector2i:
	return cell - (Ports.rotated_size(tool_def.size, rotation) - Vector2i.ONE) / 2


func ghost_fits(ghost: Placement) -> bool:
	return sim.can_place(ghost.def_id, ghost.origin, ghost.rotation)


func commit(placements: Array[Placement]) -> void:
	for placement in placements:
		sim.place(placement.def_id, placement.origin, placement.rotation)
