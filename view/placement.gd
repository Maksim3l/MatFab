class_name Placement extends RefCounted

var def_id: StringName
var origin: Vector2i
var rotation: int


func _init(id: StringName, at: Vector2i, quarter_turns: int) -> void:
	def_id = id
	origin = at
	rotation = quarter_turns


func equals(other: Placement) -> bool:
	return def_id == other.def_id and origin == other.origin and rotation == other.rotation
