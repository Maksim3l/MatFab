class_name Hud extends Control

signal pause_pressed

const GOAL_FONT_SIZE := 24
const GOAL_ROW_WIDTH := 170
const DONE_COLOR := Color("8fe388")
# One slot per buildable block, up to the ten number keys from 1 to 0.
const SLOT_COUNT := 10
const SLOT_SIZE := Vector2(64, 68)
const SYMBOL_FONT_SIZE := 28
const KEY_FONT_SIZE := 14
# Room under a slot icon for its key number.
const KEY_LABEL_ROOM := 20
const KEY_COLOR := Color(1, 1, 1, 0.55)

var tracker: GoalTracker
var goal_rows: Dictionary[int, PanelContainer] = {}
var build_tool: BuildTool
var slot_buttons: Dictionary[BuildingDef, Button] = {}

@onready var goal_panel: PanelContainer = $GoalPanel
@onready var goal_list: VBoxContainer = $GoalPanel/GoalList
@onready var toolbar: PanelContainer = $Toolbar
@onready var slot_list: HBoxContainer = $Toolbar/Slots
@onready var pause_button: Button = $PauseButton


func _ready() -> void:
	pause_button.pressed.connect(pause_pressed.emit)


func show_goals(goal_tracker: GoalTracker) -> void:
	tracker = goal_tracker
	BarStyle.style_panel(goal_panel)
	for child in goal_list.get_children():
		child.queue_free()
	goal_rows.clear()
	for number in tracker.goals:
		var row := make_goal_row(number)
		goal_list.add_child(row)
		goal_rows[number] = row
		update_goal(number, tracker.received.get(number, 0))
	tracker.counted.connect(update_goal)


# A row shows the wanted number on the left and how many arrived on the right.
func make_goal_row(number: int) -> PanelContainer:
	var row := PanelContainer.new()
	row.custom_minimum_size.x = GOAL_ROW_WIDTH
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line := HBoxContainer.new()
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(line)
	var number_label := goal_label(str(number))
	number_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(number_label)
	line.add_child(goal_label(""))
	return row


func goal_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", GOAL_FONT_SIZE)
	return label


func update_goal(number: int, count: int) -> void:
	var row := goal_rows[number]
	var line := row.get_child(0)
	var count_label: Label = line.get_child(1)
	var goal := tracker.goals[number]
	count_label.text = "%d / %d" % [count, goal]
	var done := count >= goal
	row.add_theme_stylebox_override("panel", BarStyle.slot_box(BarStyle.SLOT_COLOR, 8, DONE_COLOR if done else Color.TRANSPARENT))
	if done:
		for label: Label in line.get_children():
			label.add_theme_color_override("font_color", DONE_COLOR)


func show_toolbar(tool: BuildTool) -> void:
	build_tool = tool
	BarStyle.style_panel(toolbar)
	for child in slot_list.get_children():
		child.queue_free()
	slot_buttons.clear()
	for i in mini(build_tool.buildable.size(), SLOT_COUNT):
		var def := build_tool.buildable[i]
		var button := make_slot(def, i + 1)
		slot_list.add_child(button)
		slot_buttons[def] = button
	build_tool.state_changed.connect(refresh_toolbar)
	refresh_toolbar()


func make_slot(def: BuildingDef, slot: int) -> Button:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = SLOT_SIZE
	BarStyle.style_slot(button, KEY_LABEL_ROOM)
	button.add_child(key_label(slot))
	button.toggle_mode = true
	button.tooltip_text = def.display_name
	if def.sprite != null:
		button.icon = def.sprite
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		button.add_child(symbol_tile(def))
	button.pressed.connect(build_tool.select_slot.bind(slot))
	return button


# Blocks without art yet show the same symbol tile they are drawn with on the grid.
func symbol_tile(def: BuildingDef) -> Label:
	var tile := Label.new()
	tile.text = def.symbol
	tile.add_theme_font_size_override("font_size", SYMBOL_FONT_SIZE)
	var box := StyleBoxFlat.new()
	box.bg_color = BuildingView.FILL_COLOR
	box.border_color = BuildingView.BORDER_COLOR
	box.set_border_width_all(2)
	box.set_corner_radius_all(4)
	tile.add_theme_stylebox_override("normal", box)
	tile.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tile.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tile.offset_left = 12
	tile.offset_top = 8
	tile.offset_right = -12
	tile.offset_bottom = -22
	return tile


func key_label(slot: int) -> Label:
	var label := Label.new()
	label.text = str(slot % SLOT_COUNT)
	label.add_theme_font_size_override("font_size", KEY_FONT_SIZE)
	label.add_theme_color_override("font_color", KEY_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	label.offset_top = -20
	return label


func refresh_toolbar() -> void:
	for def in slot_buttons:
		slot_buttons[def].set_pressed_no_signal(build_tool.tool_def == def)
