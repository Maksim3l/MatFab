extends GutTest

const SettingsScript := preload("res://game/settings.gd")
const TEMP_PATH := "user://test_settings.cfg"

var settings: Node


func before_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))
	settings = autofree(SettingsScript.new())
	settings.config_path = TEMP_PATH


func after_all() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_PATH))


func test_missing_file_falls_back_to_defaults() -> void:
	settings.load_values(Registry.settings_sorted)
	for def in Registry.settings_sorted:
		assert_eq(settings.value_of(def), def.default_value, String(def.id))


func test_changed_value_survives_save_and_reload() -> void:
	var def: SettingDef = Registry.settings[&"02_music_volume"]
	settings.load_values(Registry.settings_sorted)
	settings.change(def, 0.35)
	var reloaded: Node = autofree(SettingsScript.new())
	reloaded.config_path = TEMP_PATH
	reloaded.load_values(Registry.settings_sorted)
	assert_almost_eq(reloaded.value_of(def), 0.35, 0.0001)


func test_volume_actions_reach_the_audio_buses() -> void:
	SettingActions.new().music_volume(0.5)
	assert_almost_eq(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")), linear_to_db(0.5), 0.01)
	SettingActions.new().music_volume(1.0)


func test_the_three_volume_settings_exist() -> void:
	assert_eq(Registry.settings[&"01_master_volume"].label, "Glasnost")
	assert_eq(Registry.settings[&"02_music_volume"].label, "Glasba")
	assert_eq(Registry.settings[&"03_effects_volume"].label, "Zvočni učinki")
