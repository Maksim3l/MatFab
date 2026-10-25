class_name BuildingDef extends Resource

enum Behavior { PROCESSOR, CONVEYOR, MOTHERSHIP }

@export var display_name := ""
@export var symbol := ""
@export var sprite: Texture2D
@export_range(0, 3) var sprite_turns := 0
@export var behavior := Behavior.PROCESSOR
@export var size := Vector2i.ONE
@export var inputs: Array[PortDef] = []
@export var outputs: Array[PortDef] = []
@export var operation: StringName
@export var duration := 0.5
@export var keep_selected := false

# World saves store this id; renaming the .tres drops saved buildings of this type.
var id: StringName
