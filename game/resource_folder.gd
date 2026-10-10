class_name ResourceFolder extends RefCounted


# Every .tres in the folder, sorted by file name, with `id` set to the file name.
static func load_sorted(folder_path: String) -> Array[Resource]:
	var file_names: Array[String] = []
	for file_name in ResourceLoader.list_directory(folder_path):
		if file_name.ends_with(".tres"):
			file_names.append(file_name)
	file_names.sort()
	var loaded: Array[Resource] = []
	for file_name in file_names:
		var resource := load(folder_path.path_join(file_name))
		resource.set(&"id", StringName(file_name.get_basename()))
		loaded.append(resource)
	return loaded
