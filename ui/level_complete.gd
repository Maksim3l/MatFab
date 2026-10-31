class_name LevelComplete extends OverlayMenu

signal main_menu_pressed
signal restart_pressed


func _ready() -> void:
	add_title("Stopnja opravljena")
	add_button("Začni znova", restart_pressed.emit)
	add_button("Glavni meni", main_menu_pressed.emit)
