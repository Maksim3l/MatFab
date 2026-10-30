extends GutTest

const ROOT := "user://test_saves"
const LEFT := 3

var store: SaveStore
var level: LevelDef


func before_each() -> void:
	remove_saves()
	store = SaveStore.new(ROOT)
	level = Registry.levels[&"r1_01"]


func after_all() -> void:
	remove_saves()


func remove_saves() -> void:
	var worlds := ProjectSettings.globalize_path(ROOT.path_join("worlds"))
	for file_name in DirAccess.get_files_at(worlds):
		DirAccess.remove_absolute(worlds.path_join(file_name))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(ROOT.path_join("progress.sav")))


func layout(sim: Simulation) -> Array[String]:
	var entries: Array[String] = []
	for building in sim.buildings:
		entries.append("%s %s %d %s %s %d" % [building.def.id, building.origin, building.rotation, building.inputs, building.outputs, building.timer])
	entries.sort()
	return entries


func test_world_survives_save_and_load() -> void:
	var sim := Simulation.from_level(level, Registry.buildings)
	sim.place(&"miner", Vector2i(6, 3), LEFT)
	sim.place(&"conveyor", Vector2i(5, 3), LEFT)
	sim.place(&"conveyor", Vector2i(4, 3), LEFT)
	for i in 33:
		sim.step()
	sim.tracker.received[2] = 4
	store.save_world(level.id, sim)
	assert_true(store.has_world(level.id))
	var loaded := Simulation.from_level(level, Registry.buildings)
	assert_true(store.load_world(level.id, loaded))
	assert_eq(layout(loaded), layout(sim))
	assert_eq(loaded.tracker.received, {2: 4} as Dictionary[int, int])


func test_unknown_def_id_is_skipped() -> void:
	DirAccess.make_dir_recursive_absolute(store.world_path(level.id).get_base_dir())
	store.write(store.world_path(level.id), {"buildings": [
		[&"no_such_block", Vector2i(-5, 5), 0, [], [], 0],
		[&"conveyor", Vector2i(-4, 5), 1, [3], [], 2],
	], "received": {}})
	var sim := Simulation.from_level(level, Registry.buildings)
	assert_true(store.load_world(level.id, sim))
	assert_null(sim.building_at(Vector2i(-5, 5)))
	assert_eq(sim.building_at(Vector2i(-4, 5)).inputs, [3])


func test_def_with_a_changed_port_count_loads() -> void:
	DirAccess.make_dir_recursive_absolute(store.world_path(level.id).get_base_dir())
	store.write(store.world_path(level.id), {"buildings": [
		[&"sum", Vector2i(-8, -4), 0, [1, 2, 9], [], 0],
		[&"miner", Vector2i(6, 3), 0, [], [2, 2], 0],
	], "received": {}})
	var sim := Simulation.from_level(level, Registry.buildings)
	store.load_world(level.id, sim)
	assert_eq(sim.building_at(Vector2i(-8, -4)).inputs, [1, 2])
	assert_eq(sim.building_at(Vector2i(6, 3)).inputs, [null])
	assert_eq(sim.building_at(Vector2i(6, 3)).outputs, [2])


func test_progress_survives_save_and_load() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT))
	store.save_progress([&"r1_01"] as Array[StringName], &"r1_01")
	var progress := store.load_progress()
	assert_eq(progress["completed"], [&"r1_01"] as Array[StringName])
	assert_eq(progress["last_played"], &"r1_01")


func test_missing_progress_is_empty() -> void:
	var progress := SaveStore.new("user://no_such_folder").load_progress()
	assert_eq(progress["completed"].size(), 0)
	assert_eq(progress["last_played"], &"")
