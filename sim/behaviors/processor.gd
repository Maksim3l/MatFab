class_name ProcessorBehavior extends Behavior


func tick(building: BuildingState) -> void:
	var def := building.def
	for i in def.inputs.size():
		if def.inputs[i].source == PortDef.Source.ORE:
			building.inputs[i] = sim().ore.get(Ports.world_cell(building, def.inputs[i]))
	if not building.inputs.has(null) and building.outputs.count(null) == building.outputs.size():
		building.timer += 1
		if building.timer >= building.duration_ticks():
			fire(building)
	for i in def.outputs.size():
		var number: Variant = building.outputs[i]
		if number != null and sim().offer(Ports.world_cell(building, def.outputs[i]), Ports.world_side(building, def.outputs[i]), number):
			building.outputs[i] = null


func fire(building: BuildingState) -> void:
	var def := building.def
	var result: Variant = sim().operations.callv(def.operation, building.inputs)
	var results: Array = result if result is Array else [result]
	for i in building.outputs.size():
		building.outputs[i] = results[i]
	for i in def.inputs.size():
		if def.inputs[i].source == PortDef.Source.NEIGHBOR:
			building.inputs[i] = null
	building.timer = 0


func accept(building: BuildingState, cell: Vector2i, side: int, number: int) -> bool:
	var def := building.def
	for i in def.inputs.size():
		var port := def.inputs[i]
		if port.source == PortDef.Source.NEIGHBOR and building.inputs[i] == null \
				and Ports.world_cell(building, port) == cell and Ports.world_side(building, port) == side:
			building.inputs[i] = number
			return true
	return false
