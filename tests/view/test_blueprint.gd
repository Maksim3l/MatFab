extends GutTest

const UP := 0
const RIGHT := 1

var sim: Simulation


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	sim.place(&"miner", Vector2i(6, 3), UP)
	sim.place(&"conveyor", Vector2i(6, 2), RIGHT)
	sim.place(&"conveyor", Vector2i(7, 2), RIGHT)


func entries_of(blueprint: Blueprint) -> Array[String]:
	var entries: Array[String] = []
	for part in blueprint.parts:
		entries.append("%s %s %d" % [part.def_id, part.origin, part.rotation])
	entries.sort()
	return entries


func test_capture_stores_def_offset_and_rotation() -> void:
	var blueprint := Blueprint.capture(sim, Rect2i(Vector2i(5, 1), Vector2i(4, 4)))
	assert_eq(entries_of(blueprint), ["conveyor (0, 0) 1", "conveyor (1, 0) 1", "miner (0, 1) 0"] as Array[String])
	assert_eq(blueprint.size, Vector2i(2, 2))


func test_capture_skips_the_mothership() -> void:
	var blueprint := Blueprint.capture(sim, Rect2i(Vector2i(0, 0), Vector2i(8, 8)))
	for part in blueprint.parts:
		assert_ne(part.def_id, &"mothership")


func test_rotation_turns_offsets_and_parts_clockwise() -> void:
	var blueprint := Blueprint.capture(sim, Rect2i(Vector2i(5, 1), Vector2i(4, 4))).rotated_cw()
	assert_eq(entries_of(blueprint), ["conveyor (1, 0) 2", "conveyor (1, 1) 2", "miner (0, 0) 1"] as Array[String])
	assert_eq(blueprint.size, Vector2i(2, 2))


func test_four_rotations_give_the_original_back() -> void:
	var original := Blueprint.capture(sim, Rect2i(Vector2i(5, 1), Vector2i(4, 4)))
	var turned := original.rotated_cw().rotated_cw().rotated_cw().rotated_cw()
	assert_eq(entries_of(turned), entries_of(original))


func test_fit_check_needs_every_part_to_fit() -> void:
	var blueprint := Blueprint.capture(sim, Rect2i(Vector2i(5, 1), Vector2i(4, 4)))
	assert_true(blueprint.fits(sim, Vector2i(7, 3)), "the miner lands on ore and the conveyors on free ground")
	assert_false(blueprint.fits(sim, Vector2i(-12, 5)), "the miner lands off ore")
	assert_false(blueprint.fits(sim, Vector2i(6, 2)), "overlaps the original")


func test_capture_of_empty_ground_is_empty() -> void:
	assert_true(Blueprint.capture(sim, Rect2i(Vector2i(-15, 8), Vector2i(3, 3))).is_empty())
