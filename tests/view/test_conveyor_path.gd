extends GutTest

const UP := 0
const RIGHT := 1
const DOWN := 2
const LEFT := 3


func test_straight_path_runs_from_back_edge_to_front_edge() -> void:
	assert_eq(ConveyorPath.point(DOWN, UP, 0.0), Vector2(0, 0.5))
	assert_eq(ConveyorPath.point(DOWN, UP, 0.25), Vector2(0, 0.25))
	assert_eq(ConveyorPath.point(DOWN, UP, 1.0), Vector2(0, -0.5))


func test_corner_path_turns_at_the_center() -> void:
	assert_eq(ConveyorPath.point(LEFT, UP, 0.0), Vector2(-0.5, 0))
	assert_eq(ConveyorPath.point(LEFT, UP, 0.5), Vector2.ZERO)
	assert_eq(ConveyorPath.point(LEFT, UP, 0.75), Vector2(0, -0.25))


func test_progress_adds_the_clock_fraction_and_clamps() -> void:
	assert_almost_eq(ConveyorPath.progress(2, 0.5, 5), 0.5, 0.0001)
	assert_eq(ConveyorPath.progress(-1, 0.2, 5), 0.0)
	assert_eq(ConveyorPath.progress(5, 0.9, 5), 1.0)


func test_conveyor_fed_from_its_side_is_drawn_as_a_corner() -> void:
	var sim := SimFixture.empty_sim()
	sim.place(&"conveyor", Vector2i(0, 0), UP)
	sim.place(&"conveyor", Vector2i(-1, 0), RIGHT)
	assert_eq(ConveyorPath.input_side(sim, sim.building_at(Vector2i(0, 0))), LEFT)


func test_conveyor_fed_from_behind_is_straight() -> void:
	var sim := SimFixture.empty_sim()
	sim.place(&"conveyor", Vector2i(0, 0), UP)
	sim.place(&"conveyor", Vector2i(0, 1), UP)
	sim.place(&"conveyor", Vector2i(-1, 0), RIGHT)
	assert_eq(ConveyorPath.input_side(sim, sim.building_at(Vector2i(0, 0))), DOWN)


func test_miner_output_counts_as_a_feeder() -> void:
	var sim := SimFixture.empty_sim()
	SimFixture.add_ore(sim, 1, Vector2i(-1, 0), Vector2i.ONE)
	sim.place(&"conveyor", Vector2i(0, 0), UP)
	sim.place(&"miner", Vector2i(-1, 0), RIGHT)
	assert_eq(ConveyorPath.input_side(sim, sim.building_at(Vector2i(0, 0))), LEFT)
