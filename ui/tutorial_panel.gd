class_name TutorialPanel extends PanelContainer

const TEXT_FONT_SIZE := 24
const HEADER_FONT_SIZE := 18
const HEADER_COLOR := Color(1, 1, 1, 0.55)

var tutorial: Tutorial
var sim: Simulation
var build_tool: BuildTool

@onready var step_label: Label = $Rows/Header/StepLabel
@onready var skip_button: Button = $Rows/Header/SkipButton
@onready var text_label: Label = $Rows/TextLabel
@onready var next_button: Button = $Rows/NextButton


func _ready() -> void:
	BarStyle.style_panel(self)
	step_label.add_theme_font_size_override("font_size", HEADER_FONT_SIZE)
	step_label.add_theme_color_override("font_color", HEADER_COLOR)
	text_label.add_theme_font_size_override("font_size", TEXT_FONT_SIZE)
	skip_button.pressed.connect(skip)
	next_button.pressed.connect(next)


func show_tutorial(steps: Array[TutorialStep], simulation: Simulation, tool: BuildTool) -> void:
	sim = simulation
	build_tool = tool
	tutorial = Tutorial.new(steps)
	tutorial.step_changed.connect(refresh)
	refresh()


# Polls instead of listening to signals: a conveyor drag places without the tool emitting state_changed.
func _process(_delta: float) -> void:
	if tutorial != null and not tutorial.is_finished():
		tutorial.update(sim, build_tool.tool_def)


func refresh() -> void:
	var step := tutorial.current()
	visible = step != null
	if step == null:
		return
	step_label.text = "Navodila %d / %d" % [tutorial.index + 1, tutorial.steps.size()]
	text_label.text = step.text
	next_button.visible = step.goal == TutorialStep.Goal.READ
	next_button.text = "Začni igrati" if tutorial.index == tutorial.steps.size() - 1 else "Naprej"
	skip_button.visible = tutorial.index < tutorial.steps.size() - 1


func next() -> void:
	tutorial.next()


func skip() -> void:
	tutorial.skip()
