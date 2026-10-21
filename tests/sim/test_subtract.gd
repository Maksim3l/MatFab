extends GutTest

const UP := 0
const RIGHT := 1
const DOWN := 2

var sim: Simulation


# Two miners on (-8, -2) and (-7, -2) feed a subtractor above them; the left miner is a, the right one b.
# A conveyor line runs from the subtractor to the mothership's top edge.
func build_subtract_line() -> void:
	sim.place(&"miner", Vector2i(-8, -2), UP)
	sim.place(&"miner", Vector2i(-7, -2), UP)
	assert_true(sim.place(&"subtract", Vector2i(-8, -3), UP))
	for x in range(-8, 0):
		sim.place(&"conveyor", Vector2i(x, -4), RIGHT)
	for y in range(-4, 0):
		sim.place(&"conveyor", Vector2i(0, y), DOWN)
	for i in 150:
		sim.step()


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)


func test_ore_3_minus_ore_1_feeds_2() -> void:
	sim.ore[Vector2i(-8, -2)] = 3
	build_subtract_line()
	assert_gt(sim.tracker.received.get(2, 0), 0)
	assert_false(sim.tracker.received.has(4))


func test_ore_1_minus_ore_3_feeds_nothing() -> void:
	sim.ore[Vector2i(-7, -2)] = 3
	build_subtract_line()
	assert_eq(sim.tracker.received.size(), 0)


func test_subtract_returns_only_positive_differences() -> void:
	var operations := Operations.new()
	assert_eq(operations.subtract(5, 2), 3)
	assert_null(operations.subtract(2, 5))
	assert_null(operations.subtract(3, 3))
