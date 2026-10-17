class_name MothershipBehavior extends Behavior


func accept(_building: BuildingState, _cell: Vector2i, _side: int, number: int) -> bool:
	if sim().tracker != null:
		sim().tracker.receive(number)
	return true
