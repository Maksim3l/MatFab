extends GutTest

const FOLDER := "res://tests/fixtures/sorted_settings"


func test_loads_every_tres_sorted_by_file_name() -> void:
	var loaded := ResourceFolder.load_sorted(FOLDER)
	var ids: Array[StringName] = []
	for resource in loaded:
		ids.append(resource.id)
	assert_eq(ids, [&"01_alpha", &"02_beta", &"10_gamma"] as Array[StringName])


func test_ids_come_from_file_names() -> void:
	var loaded := ResourceFolder.load_sorted(FOLDER)
	assert_eq((loaded[1] as SettingDef).label, "02_beta")
	assert_eq(loaded[1].id, &"02_beta")
