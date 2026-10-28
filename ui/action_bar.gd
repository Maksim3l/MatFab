class_name ActionBar extends Control

const BUTTON_SIZE := Vector2(150, 48)
const FONT_SIZE := 18

var build_tool: BuildTool
var buttons: Dictionary[ActionButtonDef, Button] = {}

@onready var panel: PanelContainer = $Column/Panel
@onready var button_list: VBoxContainer = $Column/Panel/ButtonList


func show_tool(tool: BuildTool, defs: Array[ActionButtonDef]) -> void:
	build_tool = tool
	BarStyle.style_panel(panel)
	for child in button_list.get_children():
		child.queue_free()
	buttons.clear()
	for def in defs:
		var button := make_button(def)
		button_list.add_child(button)
		buttons[def] = button
	build_tool.state_changed.connect(refresh)
	refresh()


func make_button(def: ActionButtonDef) -> Button:
	var button := Button.new()
	button.text = def.label
	button.icon = def.icon
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = BUTTON_SIZE
	button.add_theme_font_size_override("font_size", FONT_SIZE)
	BarStyle.style_slot(button)
	if def.toggles_property != &"":
		button.toggle_mode = true
		button.toggled.connect(func(on: bool) -> void: build_tool.set_toggle(def.toggles_property, on))
	else:
		button.pressed.connect(func() -> void: build_tool.run_command(def.command))
	return button


func refresh() -> void:
	var defs: Array[ActionButtonDef] = []
	defs.assign(buttons.keys())
	var shown := ActionButtonFilter.visible_defs(defs, build_tool.active_contexts())
	for def in buttons:
		buttons[def].visible = shown.has(def)
		if def.toggles_property != &"":
			buttons[def].set_pressed_no_signal(build_tool.get(def.toggles_property))
