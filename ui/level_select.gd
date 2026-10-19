extends Control

const DONE_COLOR := Color("8fe388")
const LEVEL_BUTTON_SIZE := Vector2(520, 110)

@onready var back_button: Button = %BackButton
@onready var sections: VBoxContainer = %Sections


func _ready() -> void:
	back_button.pressed.connect(Game.open.bind(&"main_menu"))
	var groups := LevelGroups.by_grade(Registry.levels_sorted)
	for grade in groups:
		var heading := Label.new()
		heading.text = LevelGroups.grade_title(grade)
		sections.add_child(heading)
		var buttons := HFlowContainer.new()
		buttons.add_theme_constant_override("h_separation", 20)
		buttons.add_theme_constant_override("v_separation", 20)
		sections.add_child(buttons)
		for level: LevelDef in groups[grade]:
			buttons.add_child(_level_button(level))


func _level_button(level: LevelDef) -> Button:
	var button := Button.new()
	button.text = level.title
	button.custom_minimum_size = LEVEL_BUTTON_SIZE
	if Game.completed_levels.has(level.id):
		button.add_theme_color_override("font_color", DONE_COLOR)
		button.add_theme_color_override("font_hover_color", DONE_COLOR)
	button.pressed.connect(Game.open_level.bind(level))
	return button
