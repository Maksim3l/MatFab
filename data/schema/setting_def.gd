class_name SettingDef extends Resource

enum Kind { TOGGLE, SLIDER, CHOICE }

@export var label := ""
@export var kind := Kind.SLIDER
@export var default_value := 1.0
@export var min_value := 0.0
@export var max_value := 1.0
@export var step := 0.05
@export var choices: PackedStringArray = []
@export var action: StringName

# settings.cfg stores values under this id; renaming the .tres resets the setting to its default.
var id: StringName
