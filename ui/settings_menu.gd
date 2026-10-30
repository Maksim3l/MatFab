extends Control

const LABEL_FONT_SIZE := 28
const LABEL_WIDTH := 300.0
const CONTROL_WIDTH := 420.0
const ROW_HEIGHT := 72.0

@onready var rows: VBoxContainer = $Center/Rows


func _ready() -> void:
	for def in Registry.settings_sorted:
		rows.add_child(make_row(def))
	var back := Button.new()
	back.text = "Nazaj"
	back.focus_mode = Control.FOCUS_NONE
	back.custom_minimum_size = Vector2(240, ROW_HEIGHT)
	back.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.pressed.connect(go_back)
	rows.add_child(back)


func make_row(def: SettingDef) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.custom_minimum_size.y = ROW_HEIGHT
	var label := Label.new()
	label.text = def.label
	label.custom_minimum_size.x = LABEL_WIDTH
	label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	row.add_child(label)
	var control := make_control(def)
	control.custom_minimum_size.x = CONTROL_WIDTH
	control.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(control)
	return row


func make_control(def: SettingDef) -> Control:
	var value := Settings.value_of(def)
	match def.kind:
		SettingDef.Kind.TOGGLE:
			var toggle := CheckButton.new()
			toggle.button_pressed = value >= 0.5
			toggle.toggled.connect(func(on: bool) -> void: Settings.change(def, 1.0 if on else 0.0))
			return toggle
		SettingDef.Kind.CHOICE:
			var choice := OptionButton.new()
			for option in def.choices:
				choice.add_item(option)
			choice.select(int(value))
			choice.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
			choice.item_selected.connect(func(index: int) -> void: Settings.change(def, float(index)))
			return choice
	var slider := HSlider.new()
	slider.min_value = def.min_value
	slider.max_value = def.max_value
	slider.step = def.step
	slider.value = value
	slider.custom_minimum_size.y = 48
	slider.value_changed.connect(func(changed: float) -> void: Settings.change(def, changed))
	return slider


# Back returns to the level when one is open, which keeps it paused.
func go_back() -> void:
	Game.open(&"play" if Game.sim != null else &"main_menu")
