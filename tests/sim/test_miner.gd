extends GutTest

const LEFT := 3

var sim: Simulation


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)


func test_miner_on_ore_2_feeds_2_into_the_mothership() -> void:
	assert_true(sim.place(&"miner", Vector2i(6, 3), LEFT))
	sim.place(&"conveyor", Vector2i(5, 3), LEFT)
	sim.place(&"conveyor", Vector2i(4, 3), LEFT)
	for i in 30:
		sim.step()
	assert_eq(sim.tracker.received.get(2, 0), 1)


func test_miner_produces_every_duration_while_its_output_is_free() -> void:
	sim.place(&"miner", Vector2i(6, 3), LEFT)
	sim.place(&"conveyor", Vector2i(5, 3), LEFT)
	sim.place(&"conveyor", Vector2i(4, 3), LEFT)
	for i in 130:
		sim.step()
	assert_eq(sim.tracker.received.get(2, 0), 6)


func test_placing_a_miner_off_ore_fails() -> void:
	assert_false(sim.place(&"miner", Vector2i(10, 10), 0))
	assert_false(sim.can_place(&"miner", Vector2i(-5, -2), 0))
