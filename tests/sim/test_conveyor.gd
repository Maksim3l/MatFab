extends GutTest

const DOWN := 2

var sim: Simulation


func before_each() -> void:
	sim = SimFixture.empty_sim()
	sim.tracker = GoalTracker.new({7: 5} as Dictionary[int, int])
	sim.place(&"mothership", Vector2i(0, 0), 0)


func steps(count: int) -> void:
	for i in count:
		sim.step()


func line_reaches_the_mothership_in_three_durations(cells: Array[Vector2i]) -> void:
	for cell in cells:
		sim.place(&"conveyor", cell, DOWN)
	assert_true(sim.offer(Vector2i(1, -4), PortDef.Side.DOWN, 7))
	steps(14)
	assert_eq(sim.tracker.received.get(7, 0), 0)
	sim.step()
	assert_eq(sim.tracker.received.get(7, 0), 1)


func test_line_of_three_moves_a_number_into_the_mothership_in_three_durations() -> void:
	line_reaches_the_mothership_in_three_durations([Vector2i(1, -3), Vector2i(1, -2), Vector2i(1, -1)])


func test_timing_does_not_depend_on_placement_order() -> void:
	line_reaches_the_mothership_in_three_durations([Vector2i(1, -1), Vector2i(1, -2), Vector2i(1, -3)])


func test_timing_holds_when_the_first_building_ticked_hands_over() -> void:
	var fresh := SimFixture.empty_sim()
	fresh.tracker = GoalTracker.new({7: 5} as Dictionary[int, int])
	fresh.place(&"conveyor", Vector2i(1, -2), DOWN)
	fresh.place(&"conveyor", Vector2i(1, -1), DOWN)
	fresh.place(&"mothership", Vector2i(0, 0), 0)
	fresh.offer(Vector2i(1, -3), PortDef.Side.DOWN, 7)
	for i in 9:
		fresh.step()
	assert_eq(fresh.tracker.received.get(7, 0), 0)
	fresh.step()
	assert_eq(fresh.tracker.received.get(7, 0), 1)


func test_conveyor_fed_from_its_side_passes_the_number_on() -> void:
	sim.place(&"conveyor", Vector2i(1, -1), DOWN)
	assert_true(sim.offer(Vector2i(0, -1), PortDef.Side.RIGHT, 7))
	steps(5)
	assert_eq(sim.tracker.received.get(7, 0), 1)


func test_full_slot_refuses_a_second_number() -> void:
	sim.place(&"conveyor", Vector2i(1, -1), DOWN)
	assert_true(sim.offer(Vector2i(1, -2), PortDef.Side.DOWN, 7))
	assert_false(sim.offer(Vector2i(0, -1), PortDef.Side.RIGHT, 7))


func test_conveyor_refuses_numbers_entering_through_its_front() -> void:
	sim.place(&"conveyor", Vector2i(1, -6), DOWN)
	assert_false(sim.offer(Vector2i(1, -5), PortDef.Side.UP, 7))
