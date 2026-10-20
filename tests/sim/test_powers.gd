extends GutTest

const UP := 0
const RIGHT := 1
const DOWN := 2

var sim: Simulation


# A miner on (-8, -2) feeds a one-input block above it; a conveyor line runs from the block to the mothership's top edge.
func build_line(block_id: StringName) -> void:
	sim.place(&"miner", Vector2i(-8, -2), UP)
	assert_true(sim.place(block_id, Vector2i(-8, -3), UP))
	for x in range(-8, 0):
		sim.place(&"conveyor", Vector2i(x, -4), RIGHT)
	for y in range(-4, 0):
		sim.place(&"conveyor", Vector2i(0, y), DOWN)
	for i in 150:
		sim.step()


# r1_01 only counts 2 to 6, so the mothership gets goals for the raw ore, its square and its cube.
func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	sim.tracker = GoalTracker.new({2: 10, 4: 10, 8: 10} as Dictionary[int, int])
	sim.ore[Vector2i(-8, -2)] = 2


func test_square_of_ore_2_feeds_4() -> void:
	build_line(&"square")
	assert_gt(sim.tracker.received.get(4, 0), 0)
	assert_eq(sim.tracker.received.keys(), [4])


func test_cube_of_ore_2_feeds_8() -> void:
	build_line(&"cube")
	assert_gt(sim.tracker.received.get(8, 0), 0)
	assert_eq(sim.tracker.received.keys(), [8])


func test_powers_multiply_the_input_by_itself() -> void:
	var operations := Operations.new()
	assert_eq(operations.square(3), 9)
	assert_eq(operations.cube(3), 27)
