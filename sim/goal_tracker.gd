class_name GoalTracker extends RefCounted

# The mothership asks for one goal number at a time, in data order. Every number it receives goes into
# `received`, goal or not, and numbers stored before their goal comes up count as soon as it does.

signal counted(number: int, count: int)
signal goal_changed(number: int)
signal completed

var goals: Dictionary[int, int]
# Everything the mothership has received, by number; worlds save this.
var received: Dictionary[int, int] = {}


func _init(level_goals: Dictionary[int, int]) -> void:
	goals = level_goals


func receive(number: int) -> void:
	if is_complete():
		return
	var goal_before := current_goal()
	received[number] = received.get(number, 0) + 1
	counted.emit(number, received[number])
	if current_goal() != goal_before:
		goal_changed.emit(current_goal())
	if is_complete():
		completed.emit()


# The number the mothership asks for now: the first goal in data order not yet met; -1 when all are.
func current_goal() -> int:
	for number in goals:
		if received.get(number, 0) < goals[number]:
			return number
	return -1


# How many of `number` count toward its goal, capped at the amount asked for.
func progress(number: int) -> int:
	return mini(received.get(number, 0), goals.get(number, 0))


func is_complete() -> bool:
	return current_goal() == -1
