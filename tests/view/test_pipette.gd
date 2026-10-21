extends GutTest

var sim: Simulation
var buildable: Array[BuildingDef]


func before_each() -> void:
	sim = Simulation.from_level(Registry.levels[&"r1_01"], Registry.buildings)
	buildable = Registry.levels[&"r1_01"].buildable


func test_a_building_gives_its_def_and_rotation() -> void:
	sim.place(&"conveyor", Vector2i(-3, 5), 2)
	var picked := Pipette.pick(sim, Vector2i(-3, 5), buildable)
	assert_eq(picked.def_id, &"conveyor")
	assert_eq(picked.rotation, 2)


func test_bare_ore_gives_the_first_buildable_def_with_an_ore_port() -> void:
	var picked := Pipette.pick(sim, Vector2i(7, 4), buildable)
	assert_eq(picked.def_id, &"miner")
	assert_eq(picked.rotation, Pipette.KEEP_ROTATION)


func test_empty_ground_gives_nothing() -> void:
	assert_null(Pipette.pick(sim, Vector2i(-12, 10), buildable))


func test_the_mothership_gives_nothing() -> void:
	assert_null(Pipette.pick(sim, Vector2i(1, 1), buildable))
