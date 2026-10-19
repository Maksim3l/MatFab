extends GutTest

const UP := 0
const RIGHT := 1
const DOWN := 2

var sim: Simulation


# Two miners on (-8, -2) and (-7, -2) feed a sum above them; a conveyor line runs from the sum to the mothership's top edge.
func build_sum_line() -> void:
	sim.place(&"miner", Vector2i(-8, -2), UP)
	sim.place(&"miner", Vector2i(-7, -2), UP)
	assert_true(sim.place(&"sum", Vector2i(-8, -3), UP))
	for x in range(-8, 0):
		sim.place(&"conveyor", Vector2i(x, -4), RIGHT)
	for y in range(-4, 0):
		sim.place(&"conveyor", Vector2i(0, y), DOWN)
	for i in 150:
		sim.step()


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)


func test_two_miners_on_ore_1_feed_2_through_a_sum() -> void:
	build_sum_line()
	assert_gt(sim.tracker.received.get(2, 0), 0)
	assert_false(sim.tracker.received.has(1))


func test_ore_1_and_ore_2_into_a_sum_feed_3() -> void:
	sim.ore[Vector2i(-7, -2)] = 2
	build_sum_line()
	assert_gt(sim.tracker.received.get(3, 0), 0)
	assert_false(sim.tracker.received.has(2))


func test_sum_adds_its_inputs() -> void:
	assert_eq(Operations.new().sum(2, 3), 5)
