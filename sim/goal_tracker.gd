class_name GoalTracker extends RefCounted

signal counted(number: int, count: int)
signal completed

var goals: Dictionary[int, int]
var received: Dictionary[int, int] = {}


func _init(level_goals: Dictionary[int, int]) -> void:
	goals = level_goals


func receive(number: int) -> void:
	if not goals.has(number) or is_complete():
		return
	received[number] = received.get(number, 0) + 1
	counted.emit(number, received[number])
	if is_complete():
		completed.emit()


func is_complete() -> bool:
	for number in goals:
		if received.get(number, 0) < goals[number]:
			return false
	return true
