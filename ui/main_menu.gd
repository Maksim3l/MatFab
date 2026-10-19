extends Control

@onready var continue_button: Button = %ContinueButton
@onready var play_button: Button = %PlayButton
@onready var settings_button: Button = %SettingsButton
@onready var title: Label = %Title


func _ready() -> void:
	_breathe(title)
	# The saving epic shows Nadaljuj once a last played level exists.
	continue_button.hide()
	settings_button.disabled = not Game.SCREENS.has(&"settings")
	play_button.pressed.connect(Game.open.bind(&"level_select"))
	settings_button.pressed.connect(Game.open.bind(&"settings"))


func _breathe(label: Label) -> void:
	label.resized.connect(func() -> void: label.pivot_offset = label.size / 2.0)
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "scale", Vector2(1.06, 1.06), 1.2)
	tween.tween_property(label, "scale", Vector2.ONE, 1.2)
