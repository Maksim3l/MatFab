class_name Hud extends Control

const GOAL_FONT_SIZE := 30
const DONE_COLOR := Color("8fe388")

var tracker: GoalTracker
var goal_labels: Dictionary[int, Label] = {}

@onready var goal_list: VBoxContainer = $GoalPanel/GoalList


func show_goals(goal_tracker: GoalTracker) -> void:
	tracker = goal_tracker
	for child in goal_list.get_children():
		child.queue_free()
	goal_labels.clear()
	for number in tracker.goals:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", GOAL_FONT_SIZE)
		goal_list.add_child(label)
		goal_labels[number] = label
		update_goal(number, tracker.received.get(number, 0))
	tracker.counted.connect(update_goal)


func update_goal(number: int, count: int) -> void:
	var label := goal_labels[number]
	label.text = "%d    %d / %d" % [number, count, tracker.goals[number]]
	if count >= tracker.goals[number]:
		label.add_theme_color_override("font_color", DONE_COLOR)
