class_name Behavior extends RefCounted

# Weak: the sim owns its behaviors, and a strong reference back would keep both alive forever.
var _sim_ref: WeakRef


func _init(simulation: Simulation) -> void:
	_sim_ref = weakref(simulation)


func sim() -> Simulation:
	return _sim_ref.get_ref()


func tick(_building: BuildingState) -> void:
	pass


# `side` is the building's side the number enters through.
func accept(_building: BuildingState, _cell: Vector2i, _side: int, _number: int) -> bool:
	return false
