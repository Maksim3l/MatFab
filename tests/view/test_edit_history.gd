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
