class_name PauseMenu extends OverlayMenu

signal resume_pressed
signal settings_pressed
signal main_menu_pressed

var settings_button: Button


func _ready() -> void:
	add_title("Premor")
	add_button("Nadaljuj", resume_pressed.emit)
	settings_button = add_button("Nastavitve", settings_pressed.emit)
	add_button("Glavni meni", main_menu_pressed.emit)
