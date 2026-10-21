extends GutTest

const UP := 0
const RIGHT := 1
const DOWN := 2

var sim: Simulation


# Two miners on (-8, -2) and (-7, -2) feed a divider above them; the left miner is divided by the right one.
# A conveyor line runs from the divider to the mothership's top edge.
func build_divide_line() -> void:
	sim.place(&"miner", Vector2i(-8, -2), UP)
	sim.place(&"miner", Vector2i(-7, -2), UP)
	assert_true(sim.place(&"divide", Vector2i(-8, -3), UP))
	for x in range(-8, 0):
		sim.place(&"conveyor", Vector2i(x, -4), RIGHT)
	for y in range(-4, 0):
		sim.place(&"conveyor", Vector2i(0, y), DOWN)
	for i in 150:
		sim.step()


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)


func test_ore_6_divided_by_ore_2_feeds_3() -> void:
	sim.ore[Vector2i(-8, -2)] = 6
	sim.ore[Vector2i(-7, -2)] = 2
	build_divide_line()
	assert_gt(sim.tracker.received.get(3, 0), 0)
	assert_false(sim.tracker.received.has(4))


func test_ore_5_divided_by_ore_2_feeds_nothing() -> void:
	sim.ore[Vector2i(-8, -2)] = 5
	sim.ore[Vector2i(-7, -2)] = 2
	build_divide_line()
	assert_eq(sim.tracker.received.size(), 0)


func test_divide_returns_only_whole_quotients() -> void:
	var operations := Operations.new()
	assert_eq(operations.divide(6, 3), 2)
	assert_null(operations.divide(7, 2))
	assert_null(operations.divide(2, 4))
	assert_null(operations.divide(5, 0))
