extends GutTest

const RIGHT := 1
const DOWN := 2

var sim: Simulation
var tool: BuildTool


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	tool = add_child_autofree(BuildTool.new())
	tool.show_sim(sim, Registry.levels[&"r1_01"].buildable)


func layout() -> Array[String]:
	var entries: Array[String] = []
	for building in sim.buildings:
		entries.append("%s %s %d" % [building.def.id, building.origin, building.rotation])
	entries.sort()
	return entries


func tap(def_id: StringName, cell: Vector2i) -> void:
	tool.select_def(Registry.buildings[def_id])
	tool.press(cell)
	tool.release()


func drag(def_id: StringName, cells: Array[Vector2i]) -> void:
	tool.select_def(Registry.buildings[def_id])
	tool.press(cells[0])
	for cell in cells.slice(1):
		tool.drag_to(cell)
	tool.release()


func test_undo_and_redo_of_a_tap() -> void:
	var empty := layout()
	tap(&"miner", Vector2i(6, 3))
	var placed := layout()
	tool.undo()
	assert_eq(layout(), empty)
	tool.redo()
	assert_eq(layout(), placed)


func test_a_drag_is_one_undo_step() -> void:
	var empty := layout()
	drag(&"conveyor", [Vector2i(-6, 5), Vector2i(-1, 5)] as Array[Vector2i])
	assert_eq(sim.buildings.size(), 7)
	tool.undo()
	assert_eq(layout(), empty)


func test_sequence_of_place_drag_and_rotate_restores_every_step() -> void:
	var states: Array = [layout()]
	tap(&"miner", Vector2i(6, 3))
	states.append(layout())
	drag(&"conveyor", [Vector2i(5, 3), Vector2i(4, 3), Vector2i(4, 1)] as Array[Vector2i])
	states.append(layout())
	tap(&"conveyor", Vector2i(4, 1))
	states.append(layout())
	for i in range(states.size() - 2, -1, -1):
		tool.undo()
		assert_eq(layout(), states[i], "after undo back to state %d" % i)
	for i in range(1, states.size()):
		tool.redo()
		assert_eq(layout(), states[i], "after redo to state %d" % i)


func test_redrawing_a_conveyor_line_undoes_to_the_old_route() -> void:
	drag(&"conveyor", [Vector2i(-6, 5), Vector2i(-3, 5)] as Array[Vector2i])
	var first_route := layout()
	drag(&"conveyor", [Vector2i(-6, 5), Vector2i(-6, 7)] as Array[Vector2i])
	tool.undo()
	assert_eq(layout(), first_route)


func test_a_drag_that_doubles_back_undoes_cleanly() -> void:
	var empty := layout()
	drag(&"conveyor", [Vector2i(-6, 5), Vector2i(-3, 5), Vector2i(-6, 5)] as Array[Vector2i])
	tool.undo()
	assert_eq(layout(), empty)


func test_a_new_gesture_clears_redo() -> void:
	tap(&"miner", Vector2i(6, 3))
	tool.undo()
	tap(&"miner", Vector2i(7, 3))
	assert_false(tool.history.can_redo())


func test_eraser_removes_buildings_along_the_path_as_one_gesture() -> void:
	var empty := layout()
	drag(&"conveyor", [Vector2i(-6, 5), Vector2i(-1, 5)] as Array[Vector2i])
	tap(&"miner", Vector2i(6, 3))
	var built := layout()
	tool.use_eraser()
	tool.press(Vector2i(-5, 5))
	tool.drag_to(Vector2i(-3, 5))
	assert_eq(tool.erase_marks.size(), 3)
	assert_eq(sim.buildings.size(), 8, "nothing is removed before release")
	tool.release()
	assert_eq(sim.buildings.size(), 5)
	tool.undo()
	assert_eq(layout(), built)
	tool.undo()
	tool.undo()
	assert_eq(layout(), empty)


func select(from: Vector2i, to: Vector2i) -> void:
	tool.use_selector()
	tool.press(from)
	tool.drag_to(to)
	tool.release()


func test_selection_shows_delete_copy_and_cut() -> void:
	tap(&"miner", Vector2i(6, 3))
	select(Vector2i(5, 2), Vector2i(7, 4))
	assert_eq(tool.selection, Rect2i(Vector2i(5, 2), Vector2i(3, 3)))
	assert_true(tool.active_contexts().has(ActionButtonDef.Context.SELECTION))


func test_delete_selection_removes_all_but_the_mothership_as_one_step() -> void:
	drag(&"conveyor", [Vector2i(-3, 1), Vector2i(-1, 1)] as Array[Vector2i])
	var built := layout()
	select(Vector2i(-4, -1), Vector2i(4, 4))
	tool.delete_selection()
	assert_eq(sim.buildings.size(), 1)
	assert_false(tool.has_selection())
	tool.undo()
	assert_eq(layout(), built)


func test_cut_stores_a_blueprint_and_removes_the_selection() -> void:
	drag(&"conveyor", [Vector2i(-3, 6), Vector2i(-1, 6)] as Array[Vector2i])
	select(Vector2i(-3, 6), Vector2i(-1, 6))
	tool.cut()
	assert_eq(tool.clipboard.parts.size(), 3)
	assert_eq(sim.buildings.size(), 1)


func test_paste_places_the_blueprint_when_every_part_fits() -> void:
	drag(&"conveyor", [Vector2i(-3, 6), Vector2i(-1, 6)] as Array[Vector2i])
	select(Vector2i(-3, 6), Vector2i(-1, 6))
	tool.copy()
	tool.paste()
	assert_true(tool.active_contexts().has(ActionButtonDef.Context.BLUEPRINT_TOOL))
	tool.press(Vector2i(1, 1))
	tool.release()
	assert_eq(sim.buildings.size(), 4, "a paste over the mothership places nothing")
	tool.press(Vector2i(-2, 8))
	tool.release()
	assert_eq(sim.buildings.size(), 7)
	assert_false(tool.active_contexts().has(ActionButtonDef.Context.BLUEPRINT_TOOL))
	tool.undo()
	assert_eq(sim.buildings.size(), 4)


func test_eraser_leaves_the_mothership() -> void:
	tool.use_eraser()
	tool.press(Vector2i(1, 1))
	tool.drag_to(Vector2i(2, 1))
	tool.release()
	assert_not_null(sim.building_at(Vector2i(1, 1)))
