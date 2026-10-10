extends GutTest


func test_port_def_defaults() -> void:
	var port := PortDef.new()
	assert_eq(port.cell, Vector2i.ZERO)
	assert_eq(port.side, PortDef.Side.DOWN)
	assert_eq(port.source, PortDef.Source.NEIGHBOR)


func test_port_sides_are_clockwise_from_up() -> void:
	assert_eq(PortDef.Side.UP, 0)
	assert_eq(PortDef.Side.RIGHT, 1)
	assert_eq(PortDef.Side.DOWN, 2)
	assert_eq(PortDef.Side.LEFT, 3)


func test_building_def_defaults() -> void:
	var def := BuildingDef.new()
	assert_eq(def.behavior, BuildingDef.Behavior.PROCESSOR)
	assert_eq(def.size, Vector2i.ONE)
	assert_eq(def.inputs.size(), 0)
	assert_eq(def.outputs.size(), 0)
	assert_eq(def.duration, 0.5)
	assert_false(def.keep_selected)


func test_ore_patch_defaults() -> void:
	var patch := OrePatch.new()
	assert_eq(patch.value, 1)
	assert_eq(patch.size, Vector2i(3, 3))


func test_level_def_defaults() -> void:
	var level := LevelDef.new()
	assert_eq(level.grade, 1)
	assert_eq(level.map_size, Vector2i(40, 30))
	assert_eq(level.goals.size(), 0)
	assert_eq(level.buildable.size(), 0)


func test_setting_def_defaults() -> void:
	var setting := SettingDef.new()
	assert_eq(setting.kind, SettingDef.Kind.SLIDER)
	assert_eq(setting.default_value, 1.0)
	assert_eq(setting.step, 0.05)


func test_action_button_def_defaults() -> void:
	var button := ActionButtonDef.new()
	assert_eq(button.shown_with, [ActionButtonDef.Context.ALWAYS] as Array[ActionButtonDef.Context])
	assert_eq(button.command, &"")
