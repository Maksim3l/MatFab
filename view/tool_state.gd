class_name ToolState extends Node

# What the build tool holds and what it would place; BuildTool adds the commands that change it.

signal state_changed

enum Mode { NONE, BUILD, ERASE, SELECT, BLUEPRINT }

@export var camera_rig: CameraRig

var sim: Simulation
var buildable: Array[BuildingDef] = []
var tool_def: BuildingDef
# Each def keeps the rotation it was last placed with.
var rotations: Dictionary[StringName, int] = {}
var gesture_active := false
var drag_cells: Array[Vector2i] = []
var ghosts: Array[Placement] = []
var keep_placing := false
var straight_line := false
var conveyors_flipped := false
var history := EditHistory.new()
var mode := Mode.NONE
# Buildings the eraser path has passed over; release removes them.
var erase_marks: Array[BuildingState] = []
# Cells of the current selection; a zero size means nothing is selected.
var selection := Rect2i()
var clipboard: Blueprint
# The blueprint being pasted, in its current rotation.
var blueprint: Blueprint
# The block or blueprint waiting on the map to be placed; a tap moves it, a tap on it places it.
var preview_cell := Vector2i.ZERO


# Shift held on a keyboard counts as keep_placing, Ctrl held as straight_line.
func places_multiple() -> bool:
	return keep_placing or Input.is_action_pressed(&"hold_place_multiple")


func keeps_straight_line() -> bool:
	return straight_line or Input.is_action_pressed(&"hold_straight_line")


func has_tool() -> bool:
	return tool_def != null


func has_selection() -> bool:
	return selection.has_area()


func selected_buildings() -> Array[BuildingState]:
	var cells: Array[Vector2i] = []
	for y in range(selection.position.y, selection.end.y):
		for x in range(selection.position.x, selection.end.x):
			cells.append(Vector2i(x, y))
	return RecordedEdits.buildings_under(sim, cells)


func active_contexts() -> Array[ActionButtonDef.Context]:
	var contexts: Array[ActionButtonDef.Context] = [ActionButtonDef.Context.ALWAYS]
	if has_tool():
		contexts.append(ActionButtonDef.Context.BUILDING_TOOL)
	if is_conveyor_tool():
		contexts.append(ActionButtonDef.Context.CONVEYOR_TOOL)
	if has_selection():
		contexts.append(ActionButtonDef.Context.SELECTION)
	if mode == Mode.BLUEPRINT:
		contexts.append(ActionButtonDef.Context.BLUEPRINT_TOOL)
	if clipboard != null:
		contexts.append(ActionButtonDef.Context.CLIPBOARD)
	return contexts


func tool_rotation() -> int:
	return rotations.get(tool_def.id, 0)


func is_conveyor_tool() -> bool:
	return has_tool() and tool_def.behavior == BuildingDef.Behavior.CONVEYOR


func has_preview() -> bool:
	return mode == Mode.BUILD or mode == Mode.BLUEPRINT


func preview_placements() -> Array[Placement]:
	if mode == Mode.BLUEPRINT:
		return blueprint.placements_at(blueprint_origin_under(preview_cell))
	if mode == Mode.BUILD:
		var single: Array[Placement] = [Placement.new(tool_def.id, origin_under(preview_cell, tool_rotation()), tool_rotation())]
		return single
	return []


func preview_covers(cell: Vector2i) -> bool:
	for placement in preview_placements():
		var footprint := Ports.rotated_size(sim.defs[placement.def_id].size, placement.rotation)
		if Rect2i(placement.origin, footprint).has_point(cell):
			return true
	return false


func preview_fits() -> bool:
	for placement in preview_placements():
		if not ghost_fits(placement):
			return false
	return not preview_placements().is_empty()


# The ghosts to draw: the drag while one runs, otherwise the preview.
func shown_ghosts() -> Array[Placement]:
	if gesture_active and drag_cells.size() > 1:
		return ghosts
	return preview_placements()


func view_center_cell() -> Vector2i:
	return Grid.world_to_cell(camera_rig.position) if camera_rig != null else Vector2i.ZERO


func is_same_def_building(cell: Vector2i) -> bool:
	var building := sim.building_at(cell)
	return building != null and building.def == tool_def


func refresh_ghosts() -> void:
	if mode == Mode.ERASE:
		erase_marks = RecordedEdits.buildings_under(sim, drag_cells)
		return
	if mode == Mode.SELECT:
		selection = Rect2i(drag_cells[0], Vector2i.ZERO).expand(drag_cells.back())
		selection.size += Vector2i.ONE
		return
	if mode == Mode.BLUEPRINT:
		ghosts = blueprint.placements_at(blueprint_origin_under(drag_cells.back()))
		return
	ghosts = placements_for(DragPath.lock_to_axis(drag_cells) if keeps_straight_line() else drag_cells)


func placements_for(cells: Array[Vector2i]) -> Array[Placement]:
	if is_conveyor_tool():
		return DragPath.conveyor_placements(tool_def.id, cells, tool_rotation(), conveyors_flipped)
	var origins: Array[Vector2i] = []
	for cell in cells:
		origins.append(origin_under(cell, tool_rotation()))
	var placements: Array[Placement] = []
	for origin in DragPath.stepped_origins(origins, Ports.rotated_size(tool_def.size, tool_rotation())):
		placements.append(Placement.new(tool_def.id, origin, tool_rotation()))
	return placements


# Origin that puts the block's middle cell under the finger.
func origin_under(cell: Vector2i, rotation: int) -> Vector2i:
	return cell - (Ports.rotated_size(tool_def.size, rotation) - Vector2i.ONE) / 2


func ghost_fits(ghost: Placement) -> bool:
	return sim.can_place(ghost.def_id, ghost.origin, ghost.rotation)


func blueprint_origin_under(cell: Vector2i) -> Vector2i:
	return cell - (blueprint.size - Vector2i.ONE) / 2
