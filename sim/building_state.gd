class_name BuildingState extends RefCounted

var def: BuildingDef
var origin: Vector2i
var rotation: int
# One slot per port, each an int or null. A conveyor has one input slot and no ports.
var inputs: Array = []
var outputs: Array = []
var timer := 0


func _init(building_def: BuildingDef, at: Vector2i, quarter_turns: int) -> void:
	def = building_def
	origin = at
	rotation = posmod(quarter_turns, 4)
	inputs.resize(1 if def.behavior == BuildingDef.Behavior.CONVEYOR else def.inputs.size())
	outputs.resize(def.outputs.size())


func size() -> Vector2i:
	return Ports.rotated_size(def.size, rotation)


func covered_cells() -> Array[Vector2i]:
	return Ports.covered_cells(def.size, origin, rotation)


func front_side() -> int:
	return Ports.rotate_side(PortDef.Side.UP, rotation)
