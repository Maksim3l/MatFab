class_name ConveyorBehavior extends Behavior


func tick(building: BuildingState) -> void:
	if building.inputs[0] == null:
		return
	building.timer += 1
	if building.timer >= building.duration_ticks() and sim().offer(building.origin, building.front_side(), building.inputs[0]):
		building.inputs[0] = null
		building.timer = 0


func accept(building: BuildingState, _cell: Vector2i, side: int, number: int) -> bool:
	if building.inputs[0] != null or side == building.front_side():
		return false
	building.inputs[0] = number
	building.timer = sim().arrival_timer(building)
	return true
