class_name SaveStore extends RefCounted

# store_var keeps ints, Vector2i and StringName with their types, so saved ids and cells load back as written.

var root: String


func _init(root_folder := "user://") -> void:
	root = root_folder


func progress_path() -> String:
	return root.path_join("progress.sav")


func world_path(level_id: StringName) -> String:
	return root.path_join("worlds").path_join("%s.sav" % level_id)


func save_progress(completed: Array[StringName], last_played: StringName) -> void:
	write(progress_path(), {"completed": completed, "last_played": last_played})


# {"completed": Array[StringName], "last_played": StringName}; empty values without a file.
func load_progress() -> Dictionary:
	var stored: Variant = read(progress_path())
	var completed: Array[StringName] = []
	var last_played := &""
	if stored is Dictionary:
		completed.assign(stored.get("completed", []))
		last_played = stored.get("last_played", &"")
	return {"completed": completed, "last_played": last_played}


func has_world(level_id: StringName) -> bool:
	return FileAccess.file_exists(world_path(level_id))


# Every building except the mothership as [def_id, origin, rotation, inputs, outputs, timer], and the goal counts.
func save_world(level_id: StringName, sim: Simulation) -> void:
	DirAccess.make_dir_recursive_absolute(world_path(level_id).get_base_dir())
	var buildings: Array = []
	for building in sim.buildings:
		if building.def.behavior != BuildingDef.Behavior.MOTHERSHIP:
			buildings.append([building.def.id, building.origin, building.rotation, building.inputs, building.outputs, building.timer])
	write(world_path(level_id), {"buildings": buildings, "received": sim.tracker.received})


# Loads onto a sim fresh from its level. Unknown def ids are skipped and slot arrays are resized to the
# def's current port counts, so a save stays loadable after a def changes.
func load_world(level_id: StringName, sim: Simulation) -> bool:
	var stored: Variant = read(world_path(level_id))
	if not stored is Dictionary:
		return false
	for entry in stored.get("buildings", []):
		var def_id: StringName = entry[0]
		if not sim.defs.has(def_id) or not sim.place(def_id, entry[1], entry[2]):
			continue
		var building := sim.building_at(entry[1])
		building.inputs = resized(entry[3], building.inputs.size())
		building.outputs = resized(entry[4], building.outputs.size())
		building.timer = entry[5]
	sim.tracker.received.assign(stored.get("received", {}))
	return true


static func resized(slots: Array, count: int) -> Array:
	var copy := slots.duplicate()
	copy.resize(count)
	return copy


static func write(path: String, data: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_var(data)


static func read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	return file.get_var() if file != null else null
