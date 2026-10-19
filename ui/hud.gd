class_name Hud extends Control

const GOAL_FONT_SIZE := 30
const DONE_COLOR := Color("8fe388")
const SLOT_SIZE := Vector2(140, 96)
const SLOT_FONT_SIZE := 22

var tracker: GoalTracker
var goal_labels: Dictionary[int, Label] = {}
var build_tool: BuildTool
var slot_buttons: Dictionary[BuildingDef, Button] = {}

@onready var goal_list: VBoxContainer = $GoalPanel/GoalList
@onready var toolbar: HBoxContainer = $Toolbar


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


func show_toolbar(tool: BuildTool) -> void:
	build_tool = tool
	for child in toolbar.get_children():
		child.queue_free()
	slot_buttons.clear()
	for i in build_tool.buildable.size():
		var def := build_tool.buildable[i]
		var button := Button.new()
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = SLOT_SIZE
		button.text = def.display_name
		button.add_theme_font_size_override("font_size", SLOT_FONT_SIZE)
		button.pressed.connect(build_tool.select_slot.bind(i + 1))
		toolbar.add_child(button)
		slot_buttons[def] = button
	build_tool.state_changed.connect(refresh_toolbar)
	refresh_toolbar()


func refresh_toolbar() -> void:
	for def in slot_buttons:
		slot_buttons[def].set_pressed_no_signal(build_tool.tool_def == def)
