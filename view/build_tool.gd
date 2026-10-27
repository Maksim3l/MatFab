class_name BuildTool extends Node

signal state_changed

enum Mode { NONE, BUILD, ERASE, SELECT, BLUEPRINT }

const SHORTCUT_PREFIX := "build_"

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
var _shortcut_calls: Dictionary[StringName, Callable] = {}


# Every Input Map action named build_<function> calls that function; a trailing number becomes its argument.
func _ready() -> void:
	for action in InputMap.get_actions():
		if String(action).begins_with(SHORTCUT_PREFIX):
			_shortcut_calls[action] = _call_for(String(action).trim_prefix(SHORTCUT_PREFIX))


func _shortcut_input(event: InputEvent) -> void:
	if sim == null:
		return
	for action in _shortcut_calls:
		# exact_match: with false, Shift+R also fires build_rotate_cw.
		if event.is_action_pressed(action, false, true):
			get_viewport().set_input_as_handled()
			_shortcut_calls[action].call()
			return


func _call_for(shortcut: String) -> Callable:
	var head_and_number := shortcut.rsplit("_", true, 1)
	var has_number := head_and_number.size() == 2 and head_and_number[1].is_valid_int()
	var function_name := head_and_number[0] if has_number else shortcut
	if not has_method(function_name):
		push_error("Input Map action build_%s has no function %s in build_tool.gd" % [shortcut, function_name])
	var function_call := Callable(self, function_name)
	return function_call.bind(head_and_number[1].to_int()) if has_number else function_call


# Shift held on a keyboard counts as keep_placing, Ctrl held as straight_line.
func places_multiple() -> bool:
	return keep_placing or Input.is_action_pressed(&"hold_place_multiple")


func keeps_straight_line() -> bool:
	return straight_line or Input.is_action_pressed(&"hold_straight_line")


func pipette() -> void:
	var pointer := get_viewport().get_mouse_position()
	pipette_at(Grid.world_to_cell(camera_rig.screen_to_world(pointer)))


func flip_conveyors() -> void:
	set_toggle(&"conveyors_flipped", not conveyors_flipped)


func show_sim(simulation: Simulation, buildable_defs: Array[BuildingDef]) -> void:
	sim = simulation
	buildable = buildable_defs
	history = EditHistory.new()
	drop_tool()


func has_tool() -> bool:
	return tool_def != null


func select_def(def: BuildingDef) -> void:
	cancel_gesture()
	tool_def = def
	mode = Mode.BUILD
	state_changed.emit()


func drop_tool() -> void:
	cancel_gesture()
	tool_def = null
	blueprint = null
	mode = Mode.NONE
	state_changed.emit()


func use_selector() -> void:
	cancel_gesture()
	tool_def = null
	mode = Mode.SELECT
	state_changed.emit()


func has_selection() -> bool:
	return selection.has_area()


func clear_selection() -> void:
	selection = Rect2i()
	state_changed.emit()


func selected_buildings() -> Array[BuildingState]:
	var cells: Array[Vector2i] = []
	for y in range(selection.position.y, selection.end.y):
		for x in range(selection.position.x, selection.end.x):
			cells.append(Vector2i(x, y))
	return RecordedEdits.buildings_under(sim, cells)


func delete_selection() -> void:
	RecordedEdits.remove_all(sim, history, selected_buildings())
	clear_selection()


func copy() -> void:
	if not has_selection():
		return
	var captured := Blueprint.capture(sim, selection)
	if not captured.is_empty():
		clipboard = captured
	state_changed.emit()


func cut() -> void:
	copy()
	delete_selection()


func paste() -> void:
	if clipboard == null:
		return
	cancel_gesture()
	tool_def = null
	blueprint = clipboard
	mode = Mode.BLUEPRINT
	state_changed.emit()


func use_eraser() -> void:
	cancel_gesture()
	tool_def = null
	mode = Mode.ERASE
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


func run_command(command: StringName) -> void:
	if has_method(command):
		call(command)


func set_toggle(property: StringName, on: bool) -> void:
	set(property, on)
	state_changed.emit()


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


func rotate_cw() -> void:
	rotate_tool(1)


func rotate_ccw() -> void:
	rotate_tool(3)


func rotate_tool(quarter_turns: int) -> void:
	if mode == Mode.BLUEPRINT:
		for turn in quarter_turns:
			blueprint = blueprint.rotated_cw()
		if gesture_active:
			refresh_ghosts()
		state_changed.emit()
		return
	if not has_tool():
		return
	rotations[tool_def.id] = posmod(tool_rotation() + quarter_turns, 4)
	if gesture_active:
		refresh_ghosts()
	state_changed.emit()


func center_camera() -> void:
	var mothership := sim.building_at(Vector2i.ZERO)
	camera_rig.home = Grid.cells_rect(mothership.origin, mothership.size()).get_center()
	camera_rig.center_on(camera_rig.home)
	state_changed.emit()


func pipette_at(cell: Vector2i) -> void:
	var picked := Pipette.pick(sim, cell, buildable)
	if picked == null:
		return
	if picked.rotation != Pipette.KEEP_ROTATION:
		rotations[picked.def_id] = picked.rotation
	select_def(sim.defs[picked.def_id])


func tool_rotation() -> int:
	return rotations.get(tool_def.id, 0)


func is_conveyor_tool() -> bool:
	return has_tool() and tool_def.behavior == BuildingDef.Behavior.CONVEYOR


func press(cell: Vector2i) -> void:
	if mode == Mode.NONE:
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
	if mode == Mode.ERASE:
		RecordedEdits.remove_all(sim, history, erase_marks)
		cancel_gesture()
		return
	if mode == Mode.SELECT:
		cancel_gesture()
		state_changed.emit()
		return
	if mode == Mode.BLUEPRINT:
		release_blueprint()
		return
	if drag_cells.size() == 1 and is_same_def_building(drag_cells[0]):
		rotate_building(drag_cells[0])
		cancel_gesture()
		return
	RecordedEdits.place_all(sim, history, ghosts)
	if ghosts.size() > 0:
		rotations[tool_def.id] = ghosts.back().rotation
	cancel_gesture()
	if not (places_multiple() or tool_def.keep_selected):
		drop_tool()


func is_same_def_building(cell: Vector2i) -> bool:
	var building := sim.building_at(cell)
	return building != null and building.def == tool_def


# A tap on a building of the tool's def turns it a quarter clockwise in place, when the turned block fits.
func rotate_building(cell: Vector2i) -> void:
	var building := sim.building_at(cell)
	var before := RecordedEdits.placement_of(building)
	var turned := Placement.new(before.def_id, before.origin, posmod(before.rotation + 1, 4))
	if building.def.behavior != BuildingDef.Behavior.CONVEYOR:
		sim.remove(cell)
	if not sim.place(turned.def_id, turned.origin, turned.rotation):
		sim.place(before.def_id, before.origin, before.rotation)
		return
	history.record([turned] as Array[Placement], [before] as Array[Placement])
	rotations[turned.def_id] = turned.rotation
	state_changed.emit()


func undo() -> void:
	cancel_gesture()
	history.undo(sim)
	state_changed.emit()


func redo() -> void:
	cancel_gesture()
	history.redo(sim)
	state_changed.emit()


func cancel_gesture() -> void:
	gesture_active = false
	drag_cells.clear()
	ghosts.clear()
	erase_marks.clear()


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


# The ghost follows the finger with the blueprint centered under it, and places only when every part fits.
func release_blueprint() -> void:
	var origin := blueprint_origin_under(drag_cells.back())
	var fits := blueprint.fits(sim, origin)
	if fits:
		RecordedEdits.place_all(sim, history, blueprint.placements_at(origin))
	cancel_gesture()
	if fits and not places_multiple():
		drop_tool()


func blueprint_origin_under(cell: Vector2i) -> Vector2i:
	return cell - (blueprint.size - Vector2i.ONE) / 2
