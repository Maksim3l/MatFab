extends Node

const BLOCKS_FOLDER := "res://data/blocks"
const LEVELS_FOLDER := "res://data/levels"
const SETTINGS_FOLDER := "res://data/settings"
const CONTROLS_FOLDER := "res://data/controls"

var buildings: Dictionary[StringName, BuildingDef] = {}
var levels: Dictionary[StringName, LevelDef] = {}
var settings: Dictionary[StringName, SettingDef] = {}
var controls: Dictionary[StringName, ActionButtonDef] = {}

var levels_sorted: Array[LevelDef] = []
var settings_sorted: Array[SettingDef] = []
var controls_sorted: Array[ActionButtonDef] = []


func _init() -> void:
	for resource in ResourceFolder.load_sorted(BLOCKS_FOLDER):
		buildings[resource.id] = resource
	levels_sorted.assign(ResourceFolder.load_sorted(LEVELS_FOLDER))
	for level in levels_sorted:
		levels[level.id] = level
	settings_sorted.assign(ResourceFolder.load_sorted(SETTINGS_FOLDER))
	for setting in settings_sorted:
		settings[setting.id] = setting
	controls_sorted.assign(ResourceFolder.load_sorted(CONTROLS_FOLDER))
	for control in controls_sorted:
		controls[control.id] = control
