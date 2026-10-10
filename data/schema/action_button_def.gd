class_name ActionButtonDef extends Resource

enum Context { ALWAYS, BUILDING_TOOL, CONVEYOR_TOOL, BLUEPRINT_TOOL, SELECTION, CLIPBOARD }

@export var label := ""
@export var icon: Texture2D
@export var shown_with: Array[Context] = [Context.ALWAYS]
@export var command: StringName
@export var toggles_property: StringName

var id: StringName
