class_name BuildTool extends ToolState

const SHORTCUT_PREFIX := "build_"

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


func select_def(def: BuildingDef) -> void:
	cancel_gesture()
	tool_def = def
	mode = Mode.BUILD
	preview_cell = view_center_cell()
	state_changed.emit()


func drop_tool() -> void:
	cancel_gesture()
	tool_def = null
	blueprint = null
	mode = Mode.NONE
	state_changed.emit()


# Drops the tool or the selection; false when there was neither, which lets back open the pause menu.
func cancel() -> bool:
	if has_selection():
		cancel_gesture()
		clear_selection()
		return true
	if mode != Mode.NONE:
		drop_tool()
		return true
	return false


func use_selector() -> void:
	cancel_gesture()
	tool_def = null
	mode = Mode.SELECT
	state_changed.emit()


func clear_selection() -> void:
	selection = Rect2i()
	state_changed.emit()


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
	preview_cell = view_center_cell()
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
		if drag_cells.size() == 1 and preview_covers(drag_cells[0]):
			cancel_gesture()
			place_preview()
		else:
			preview_cell = drag_cells.back()
			cancel_gesture()
			state_changed.emit()
		return
	if drag_cells.size() == 1:
		release_tap(drag_cells[0])
		return
	RecordedEdits.place_all(sim, history, ghosts)
	if ghosts.size() > 0:
		rotations[tool_def.id] = ghosts.back().rotation
		preview_cell = drag_cells.back()
	cancel_gesture()
	if not (places_multiple() or tool_def.keep_selected):
		drop_tool()


# A tap on a block of the tool's def turns it; on the preview it places the preview; anywhere else it moves the preview there.
func release_tap(cell: Vector2i) -> void:
	cancel_gesture()
	if is_same_def_building(cell):
		rotate_building(cell)
	elif preview_covers(cell):
		place_preview()
	else:
		preview_cell = cell
		state_changed.emit()


# Places the preview when every part of it fits; the tool then drops as after any other placement.
func place_preview() -> void:
	if not has_preview() or not preview_fits():
		return
	RecordedEdits.place_all(sim, history, preview_placements())
	if not (places_multiple() or (has_tool() and tool_def.keep_selected)):
		drop_tool()
	else:
		state_changed.emit()


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
