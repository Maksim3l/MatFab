class_name BlockInfoMenu extends Control

signal close_pressed

const ICON_SIZE := Vector2(80, 80)
const NAME_FONT_SIZE := 28
const TEXT_FONT_SIZE := 22
const SYMBOL_FONT_SIZE := 34

@onready var panel: PanelContainer = $Center/Panel
@onready var rows: VBoxContainer = $Center/Panel/Column/Scroll/Rows
@onready var close_button: Button = $Center/Panel/Column/CloseButton


func _ready() -> void:
	BarStyle.style_panel(panel)
	close_button.pressed.connect(close_pressed.emit)


# One row per block: its picture, its name and what it does.
func show_blocks(defs: Array[BuildingDef]) -> void:
	for child in rows.get_children():
		child.queue_free()
	for def in defs:
		rows.add_child(make_row(def))
	show()


func make_row(def: BuildingDef) -> PanelContainer:
	var row := PanelContainer.new()
	row.add_theme_stylebox_override("panel", BarStyle.slot_box(BarStyle.SLOT_COLOR, 8))
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 16)
	row.add_child(line)
	line.add_child(make_icon(def))
	var words := VBoxContainer.new()
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	words.alignment = BoxContainer.ALIGNMENT_CENTER
	line.add_child(words)
	words.add_child(make_label(def.display_name, NAME_FONT_SIZE))
	words.add_child(make_label(def.description, TEXT_FONT_SIZE))
	return row


# Blocks without art yet show the symbol they are drawn with on the grid.
func make_icon(def: BuildingDef) -> Control:
	if def.sprite != null:
		var picture := TextureRect.new()
		picture.texture = def.sprite
		picture.custom_minimum_size = ICON_SIZE
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		return picture
	var tile := make_label(def.symbol, SYMBOL_FONT_SIZE)
	tile.custom_minimum_size = ICON_SIZE
	tile.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tile.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tile.autowrap_mode = TextServer.AUTOWRAP_OFF
	var box := StyleBoxFlat.new()
	box.bg_color = BuildingView.FILL_COLOR
	box.border_color = BuildingView.BORDER_COLOR
	box.set_border_width_all(2)
	box.set_corner_radius_all(4)
	tile.add_theme_stylebox_override("normal", box)
	return tile


func make_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	return label
