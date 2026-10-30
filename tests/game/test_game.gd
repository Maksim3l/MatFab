extends GutTest


func after_each() -> void:
	Game.sim = null
	Game.level = null
	Game.paused = false


func test_steps_stop_while_paused() -> void:
	Game.level = Registry.levels[&"r1_01"]
	Game.sim = Simulation.from_level(Game.level, Registry.buildings)
	Game.clock = SimClock.new()
	Game.sim.place(&"miner", Vector2i(6, 3), 3)
	var miner := Game.sim.building_at(Vector2i(6, 3))
	Game.paused = true
	Game.step_sim(1.0)
	assert_eq(miner.timer, 0)
	Game.paused = false
	Game.step_sim(0.5)
	assert_eq(miner.timer, 10)


func test_cancel_reports_whether_it_dropped_anything() -> void:
	var sim := Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	var tool: BuildTool = add_child_autofree(BuildTool.new())
	tool.show_sim(sim, Registry.levels[&"r1_01"].buildable)
	assert_false(tool.cancel())
	tool.select_slot(1)
	assert_true(tool.cancel())
	assert_false(tool.has_tool())
	tool.use_selector()
	tool.press(Vector2i(4, 4))
	tool.release()
	assert_true(tool.cancel(), "drops the selection")
	assert_true(tool.cancel(), "then the selector")
	assert_false(tool.cancel())
