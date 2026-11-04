extends GutTest

var tracker: GoalTracker


func before_each() -> void:
	tracker = GoalTracker.new({2: 2, 3: 1} as Dictionary[int, int])
	watch_signals(tracker)


func test_asks_for_one_goal_at_a_time_in_data_order() -> void:
	assert_eq(tracker.current_goal(), 2)
	tracker.receive(2)
	assert_eq(tracker.current_goal(), 2)
	tracker.receive(2)
	assert_eq(tracker.current_goal(), 3)
	assert_signal_emitted_with_parameters(tracker, "goal_changed", [3])


func test_every_number_goes_into_the_inventory() -> void:
	tracker.receive(7)
	tracker.receive(2)
	assert_eq(tracker.received, {7: 1, 2: 1} as Dictionary[int, int])
	assert_signal_emit_count(tracker, "counted", 2)
	assert_eq(tracker.current_goal(), 2, "a 7 does not move the goal on")


func test_numbers_stored_early_count_when_their_goal_comes_up() -> void:
	tracker.receive(3)
	assert_eq(tracker.current_goal(), 2)
	tracker.receive(2)
	tracker.receive(2)
	assert_true(tracker.is_complete(), "the 3 delivered first already meets the next goal")


func test_progress_is_capped_at_the_amount_asked_for() -> void:
	for i in 5:
		tracker.receive(2)
	assert_eq(tracker.progress(2), 2)
	assert_eq(tracker.received[2], 5)


func test_completed_emits_once_and_later_numbers_are_ignored() -> void:
	for number in [2, 3, 2, 2, 3]:
		tracker.receive(number)
	assert_true(tracker.is_complete())
	assert_eq(tracker.current_goal(), -1)
	assert_signal_emit_count(tracker, "completed", 1)
	assert_eq(tracker.received, {2: 2, 3: 1} as Dictionary[int, int])


func test_mothership_accepts_from_all_four_sides() -> void:
	var sim := Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	assert_true(sim.offer(Vector2i(1, -1), PortDef.Side.DOWN, 2))
	assert_true(sim.offer(Vector2i(4, 1), PortDef.Side.LEFT, 3))
	assert_true(sim.offer(Vector2i(2, 4), PortDef.Side.UP, 4))
	assert_true(sim.offer(Vector2i(-1, 2), PortDef.Side.RIGHT, 9))
	assert_eq(sim.tracker.received, {2: 1, 3: 1, 4: 1, 9: 1} as Dictionary[int, int])
