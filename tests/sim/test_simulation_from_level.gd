extends GutTest

var sim: Simulation


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)


func test_ore_comes_from_the_patches() -> void:
	assert_eq(sim.ore.size(), 18)
	assert_eq(sim.ore[Vector2i(-8, -2)], 1)
	assert_eq(sim.ore[Vector2i(-6, 0)], 1)
	assert_eq(sim.ore[Vector2i(6, 3)], 2)
	assert_eq(sim.ore[Vector2i(8, 5)], 2)
	assert_false(sim.ore.has(Vector2i(-9, -2)))


func test_mothership_covers_its_four_by_four_cells_from_the_origin() -> void:
	var mothership := sim.building_at(Vector2i.ZERO)
	assert_eq(mothership.def.id, &"mothership")
	for y in 4:
		for x in 4:
			assert_eq(sim.building_at(Vector2i(x, y)), mothership)
	assert_eq(sim.cells.size(), 16)


func test_map_bounds_are_centered_on_the_origin() -> void:
	assert_eq(sim.bounds, Rect2i(Vector2i(-20, -15), Vector2i(40, 30)))
