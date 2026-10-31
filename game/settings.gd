extends Node

const DEFAULT_PATH := "user://settings.cfg"
const SECTION := "settings"

var config_path := DEFAULT_PATH
var values: Dictionary[StringName, float] = {}
var actions := SettingActions.new()


func _ready() -> void:
	load_values(Registry.settings_sorted)
	apply_all(Registry.settings_sorted)


# Stored values, with the def's default for anything the file does not hold.
func load_values(defs: Array[SettingDef]) -> void:
	var config := ConfigFile.new()
	config.load(config_path)
	values.clear()
	for def in defs:
		values[def.id] = float(config.get_value(SECTION, String(def.id), def.default_value))


func apply_all(defs: Array[SettingDef]) -> void:
	for def in defs:
		apply(def)


func apply(def: SettingDef) -> void:
	if actions.has_method(def.action):
		actions.call(def.action, values[def.id])


func value_of(def: SettingDef) -> float:
	return values.get(def.id, def.default_value)


func change(def: SettingDef, value: float) -> void:
	values[def.id] = value
	apply(def)
	save_values()


func save_values() -> void:
	var config := ConfigFile.new()
	for id in values:
		config.set_value(SECTION, String(id), values[id])
	config.save(config_path)
