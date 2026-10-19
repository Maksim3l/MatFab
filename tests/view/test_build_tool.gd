extends GutTest

const RIGHT := 1

var sim: Simulation
var tool: BuildTool


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	tool = add_child_autofree(BuildTool.new())
	tool.show_sim(sim, Registry.levels[&"r1_01"].buildable)


func test_conveyor_drag_places_a_line_on_release() -> void:
	tool.select_def(Registry.buildings[&"conveyor"])
	tool.press(Vector2i(-6, 1))
	tool.drag_to(Vector2i(-2, 1))
	assert_eq(sim.buildings.size(), 1, "nothing places before release")
	tool.release()
	assert_eq(sim.buildings.size(), 6)
	assert_eq(sim.building_at(Vector2i(-4, 1)).rotation, RIGHT)


func test_conveyor_stays_selected_and_miner_drops() -> void:
	tool.select_def(Registry.buildings[&"conveyor"])
	tool.press(Vector2i(-6, 1))
	tool.release()
	assert_true(tool.has_tool())
	tool.select_def(Registry.buildings[&"miner"])
	tool.press(Vector2i(6, 3))
	tool.release()
	assert_false(tool.has_tool())
	assert_eq(sim.building_at(Vector2i(6, 3)).def.id, &"miner")


func test_cancel_places_nothing() -> void:
	tool.select_def(Registry.buildings[&"conveyor"])
	tool.press(Vector2i(-6, 1))
	tool.drag_to(Vector2i(-3, 1))
	tool.cancel_gesture()
	tool.release()
	assert_eq(sim.buildings.size(), 1)


func test_selecting_the_active_slot_drops_the_tool() -> void:
	tool.select_slot(1)
	assert_true(tool.has_tool())
	tool.select_slot(1)
	assert_false(tool.has_tool())
