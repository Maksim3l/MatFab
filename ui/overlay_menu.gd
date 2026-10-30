class_name OverlayMenu extends Control

const BUTTON_SIZE := Vector2(320, 76)
const BUTTON_FONT_SIZE := 30
const TITLE_FONT_SIZE := 44

@onready var items: VBoxContainer = $Center/Items


func add_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	items.add_child(label)
	return label


func add_button(text: String, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = BUTTON_SIZE
	button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	button.pressed.connect(on_pressed)
	items.add_child(button)
	return button
