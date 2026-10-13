extends GutTest


func test_registry_loads_the_core_blocks() -> void:
	for id in [&"mothership", &"conveyor", &"miner"]:
		assert_true(Registry.buildings.has(id), "missing block %s" % id)
		assert_eq(Registry.buildings[id].id, id)


func test_registry_loads_the_first_level() -> void:
	var level: LevelDef = Registry.levels[&"r1_01"]
	assert_eq(level.title, "Prvi koraki")
	assert_eq(level.goals, {2: 10, 3: 10, 4: 10, 5: 10, 6: 10} as Dictionary[int, int])
	assert_eq(level.buildable, [Registry.buildings[&"conveyor"], Registry.buildings[&"miner"]] as Array[BuildingDef])


func test_core_blocks_pass_the_operation_check() -> void:
	var defs: Array[BuildingDef] = []
	defs.assign(Registry.buildings.values())
	assert_eq(OperationCheck.find_problems(defs).size(), 0)


func test_core_block_values() -> void:
	var miner: BuildingDef = Registry.buildings[&"miner"]
	assert_eq(miner.display_name, "Rudar")
	assert_eq(miner.inputs[0].source, PortDef.Source.ORE)
	assert_eq(miner.outputs[0].side, PortDef.Side.UP)
	assert_eq(miner.duration, 1.0)
	var conveyor: BuildingDef = Registry.buildings[&"conveyor"]
	assert_eq(conveyor.behavior, BuildingDef.Behavior.CONVEYOR)
	assert_eq(conveyor.duration, 0.25)
	assert_true(conveyor.keep_selected)
	assert_eq(Registry.buildings[&"mothership"].size, Vector2i(4, 4))
