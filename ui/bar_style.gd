class_name BarStyle

# Shared look of the HUD bars: a dark rounded panel holding faint slots, with the active slot framed.
const BAR_COLOR := Color(0.11, 0.13, 0.18, 0.85)
const SLOT_COLOR := Color(1, 1, 1, 0.06)
const SLOT_HOVER_COLOR := Color(1, 1, 1, 0.14)
const SELECTED_COLOR := Color("f0a03c")


static func style_panel(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", rounded_box(BAR_COLOR, 16, 10))


static func style_slot(button: Button, bottom_margin := 8) -> void:
	button.add_theme_stylebox_override("normal", slot_box(SLOT_COLOR, bottom_margin))
	button.add_theme_stylebox_override("hover", slot_box(SLOT_HOVER_COLOR, bottom_margin))
	button.add_theme_stylebox_override("pressed", slot_box(SLOT_HOVER_COLOR, bottom_margin, SELECTED_COLOR))
	button.add_theme_stylebox_override("hover_pressed", slot_box(SLOT_HOVER_COLOR, bottom_margin, SELECTED_COLOR))


static func slot_box(color: Color, bottom_margin: int, border := Color.TRANSPARENT) -> StyleBoxFlat:
	var box := rounded_box(color, 10, 8)
	box.content_margin_bottom = bottom_margin
	if border.a > 0:
		box.set_border_width_all(3)
		box.border_color = border
	return box


static func rounded_box(color: Color, radius: int, margin: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.set_content_margin_all(margin)
	return box
