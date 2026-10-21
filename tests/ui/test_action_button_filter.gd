extends GutTest


func make_def(id: StringName, contexts: Array[ActionButtonDef.Context]) -> ActionButtonDef:
	var def := ActionButtonDef.new()
	def.id = id
	def.shown_with = contexts
	return def


func ids_of(defs: Array[ActionButtonDef]) -> Array[StringName]:
	var ids: Array[StringName] = []
	for def in defs:
		ids.append(def.id)
	return ids


func test_shows_defs_whose_context_is_active_in_the_given_order() -> void:
	var defs: Array[ActionButtonDef] = [
		make_def(&"01_rotate", [ActionButtonDef.Context.BUILDING_TOOL, ActionButtonDef.Context.BLUEPRINT_TOOL]),
		make_def(&"04_flip", [ActionButtonDef.Context.CONVEYOR_TOOL]),
		make_def(&"13_center", [ActionButtonDef.Context.ALWAYS]),
	]
	var none: Array[ActionButtonDef.Context] = []
	assert_eq(ids_of(ActionButtonFilter.visible_defs(defs, none)), [&"13_center"] as Array[StringName])
	var building: Array[ActionButtonDef.Context] = [ActionButtonDef.Context.BUILDING_TOOL]
	assert_eq(ids_of(ActionButtonFilter.visible_defs(defs, building)), [&"01_rotate", &"13_center"] as Array[StringName])
	var conveyor: Array[ActionButtonDef.Context] = [ActionButtonDef.Context.BUILDING_TOOL, ActionButtonDef.Context.CONVEYOR_TOOL]
	assert_eq(ids_of(ActionButtonFilter.visible_defs(defs, conveyor)), [&"01_rotate", &"04_flip", &"13_center"] as Array[StringName])


func test_registry_controls_are_in_file_name_order() -> void:
	var ids: Array[String] = []
	for def in Registry.controls_sorted:
		ids.append(String(def.id))
	var sorted := ids.duplicate()
	sorted.sort()
	assert_eq(ids, sorted)
	assert_true(ids.has("01_rotate"))
	assert_true(ids.has("13_center"))
