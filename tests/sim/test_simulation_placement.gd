extends GutTest

var sim: Simulation


func before_each() -> void:
	sim = SimFixture.empty_sim()


func test_place_fills_every_covered_cell() -> void:
	assert_true(sim.place(&"mothership", Vector2i(0, 0), 0))
	assert_eq(sim.cells.size(), 16)
	assert_eq(sim.building_at(Vector2i(3, 3)), sim.building_at(Vector2i(0, 0)))


func test_place_fails_outside_the_map() -> void:
	assert_false(sim.place(&"conveyor", Vector2i(20, 0), 0))
	assert_false(sim.place(&"mothership", Vector2i(18, 0), 0))
	assert_true(sim.place(&"conveyor", Vector2i(19, 14), 0))


func test_place_fails_on_overlap() -> void:
	sim.place(&"mothership", Vector2i(0, 0), 0)
	assert_false(sim.place(&"conveyor", Vector2i(2, 2), 0))


func test_place_fails_with_an_ore_port_off_ore() -> void:
	assert_false(sim.place(&"miner", Vector2i(5, 5), 0))
	SimFixture.add_ore(sim, 1, Vector2i(5, 5), Vector2i.ONE)
	assert_true(sim.place(&"miner", Vector2i(5, 5), 0))


func test_conveyor_on_conveyor_replaces_it_and_keeps_its_number() -> void:
	sim.place(&"conveyor", Vector2i(1, 1), 0)
	sim.building_at(Vector2i(1, 1)).inputs[0] = 7
	assert_true(sim.place(&"conveyor", Vector2i(1, 1), 1))
	var replacement := sim.building_at(Vector2i(1, 1))
	assert_eq(replacement.rotation, 1)
	assert_eq(replacement.inputs[0], 7)
	assert_eq(sim.buildings.size(), 1)


func test_remove_clears_every_covered_cell() -> void:
	SimFixture.add_ore(sim, 1, Vector2i(5, 5), Vector2i.ONE)
	sim.place(&"miner", Vector2i(5, 5), 0)
	assert_true(sim.remove(Vector2i(5, 5)))
	assert_eq(sim.cells.size(), 0)
	assert_eq(sim.buildings.size(), 0)


func test_remove_leaves_the_mothership() -> void:
	sim.place(&"mothership", Vector2i(0, 0), 0)
	assert_false(sim.remove(Vector2i(1, 1)))
	assert_eq(sim.cells.size(), 16)


func test_remove_on_empty_ground_returns_false() -> void:
	assert_false(sim.remove(Vector2i(4, 4)))


func test_duration_converts_to_ticks_at_20_per_second() -> void:
	assert_eq(Simulation.ticks_for(0.25), 5)
	assert_eq(Simulation.ticks_for(1.0), 20)
