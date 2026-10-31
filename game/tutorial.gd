class_name Tutorial extends RefCounted

signal step_changed
signal finished

var steps: Array[TutorialStep]
var index := 0


func _init(level_steps: Array[TutorialStep]) -> void:
	steps = level_steps


func current() -> TutorialStep:
	return steps[index] if index < steps.size() else null


func is_finished() -> bool:
	return index >= steps.size()


# Moves past every step the player has already done, so a step finished early is skipped.
func update(sim: Simulation, tool_def: BuildingDef) -> void:
	while not is_finished() and is_done(current(), sim, tool_def):
		next()


func next() -> void:
	if is_finished():
		return
	index += 1
	step_changed.emit()
	if is_finished():
		finished.emit()


func skip() -> void:
	if is_finished():
		return
	index = steps.size()
	step_changed.emit()
	finished.emit()


static func is_done(step: TutorialStep, sim: Simulation, tool_def: BuildingDef) -> bool:
	match step.goal:
		TutorialStep.Goal.SELECT:
			return tool_def != null and tool_def == step.block
		TutorialStep.Goal.PLACE:
			return placed_count(sim, step.block) >= step.amount
		TutorialStep.Goal.DELIVER:
			return delivered_count(sim.tracker) >= step.amount
	return false


static func placed_count(sim: Simulation, def: BuildingDef) -> int:
	var count := 0
	for building in sim.buildings:
		if building.def == def:
			count += 1
	return count


static func delivered_count(tracker: GoalTracker) -> int:
	var count := 0
	for number in tracker.received:
		count += tracker.received[number]
	return count
