extends GutTest

var sim: Simulation
var miner: BuildingDef


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	miner = Registry.buildings[&"miner"]


func make_step(goal: TutorialStep.Goal, block: BuildingDef = null, amount := 1) -> TutorialStep:
	var step := TutorialStep.new()
	step.goal = goal
	step.block = block
	step.amount = amount
	return step


func make_tutorial(steps: Array[TutorialStep]) -> Tutorial:
	var tutorial := Tutorial.new(steps)
	watch_signals(tutorial)
	return tutorial


func test_read_waits_for_next() -> void:
	var tutorial := make_tutorial([make_step(TutorialStep.Goal.READ)])
	tutorial.update(sim, miner)
	assert_eq(tutorial.index, 0)
	tutorial.next()
	assert_true(tutorial.is_finished())
	assert_signal_emit_count(tutorial, "finished", 1)


func test_select_finishes_when_the_block_is_the_tool() -> void:
	var tutorial := make_tutorial([make_step(TutorialStep.Goal.SELECT, miner)])
	tutorial.update(sim, null)
	tutorial.update(sim, Registry.buildings[&"conveyor"])
	assert_eq(tutorial.index, 0)
	tutorial.update(sim, miner)
	assert_true(tutorial.is_finished())


func test_place_counts_buildings_of_the_block() -> void:
	var conveyor: BuildingDef = Registry.buildings[&"conveyor"]
	var tutorial := make_tutorial([make_step(TutorialStep.Goal.PLACE, conveyor, 2)])
	sim.place(&"conveyor", Vector2i(6, 6), 0)
	tutorial.update(sim, null)
	assert_eq(tutorial.index, 0)
	sim.place(&"conveyor", Vector2i(6, 7), 0)
	tutorial.update(sim, null)
	assert_true(tutorial.is_finished())


func test_deliver_counts_goal_numbers_the_mothership_received() -> void:
	var tutorial := make_tutorial([make_step(TutorialStep.Goal.DELIVER)])
	sim.tracker.receive(1)
	tutorial.update(sim, null)
	assert_eq(tutorial.index, 0, "1 is not a goal of r1_01")
	sim.tracker.receive(2)
	tutorial.update(sim, null)
	assert_true(tutorial.is_finished())


func test_steps_done_early_are_skipped_together() -> void:
	var tutorial := make_tutorial([
		make_step(TutorialStep.Goal.SELECT, miner),
		make_step(TutorialStep.Goal.PLACE, miner),
		make_step(TutorialStep.Goal.READ),
	])
	sim.place(&"miner", Vector2i(6, 3), 3)
	tutorial.update(sim, miner)
	assert_eq(tutorial.index, 2)
	assert_signal_emit_count(tutorial, "step_changed", 2)


func test_skip_finishes_once() -> void:
	var tutorial := make_tutorial([make_step(TutorialStep.Goal.READ), make_step(TutorialStep.Goal.READ)])
	tutorial.skip()
	tutorial.skip()
	tutorial.next()
	assert_null(tutorial.current())
	assert_signal_emit_count(tutorial, "finished", 1)


# The layouts the r0_01 steps describe: two miners under a sum, a conveyor up into the mothership.
func test_tutorial_level_layout_delivers_3_and_4() -> void:
	var tutorial_sim := Simulation.from_level(Registry.levels[&"r0_01"], Registry.buildings)
	assert_true(tutorial_sim.place(&"miner", Vector2i(0, 9), 0), "miner on 1")
	assert_true(tutorial_sim.place(&"miner", Vector2i(1, 9), 0), "miner on 2")
	assert_true(tutorial_sim.place(&"miner", Vector2i(2, 9), 0), "second miner on 2")
	assert_true(tutorial_sim.place(&"miner", Vector2i(3, 9), 0), "third miner on 2")
	assert_true(tutorial_sim.place(&"sum", Vector2i(0, 8), 0), "1 + 2")
	assert_true(tutorial_sim.place(&"sum", Vector2i(2, 8), 0), "2 + 2")
	for x in [0, 2]:
		for y in [7, 6, 5, 4]:
			assert_true(tutorial_sim.place(&"conveyor", Vector2i(x, y), 0))
	for i in 100:
		tutorial_sim.step()
	assert_gt(tutorial_sim.tracker.received.get(3, 0), 0)
	assert_gt(tutorial_sim.tracker.received.get(4, 0), 0)


func test_only_the_tutorial_level_has_a_tutorial() -> void:
	for level in Registry.levels_sorted:
		assert_eq(level.tutorial.is_empty(), level.id != &"r0_01", "%s" % level.id)


func test_level_tutorials_only_wait_for_buildable_blocks() -> void:
	for level in Registry.levels_sorted:
		for step in level.tutorial:
			assert_ne(step.text, "", "%s has a step without text" % level.id)
			if step.goal in [TutorialStep.Goal.SELECT, TutorialStep.Goal.PLACE]:
				assert_true(level.buildable.has(step.block), "%s waits for a block it does not offer" % level.id)
