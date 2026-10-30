class_name LevelComplete extends OverlayMenu

signal main_menu_pressed


func _ready() -> void:
	add_title("Stopnja opravljena")
	add_button("Glavni meni", main_menu_pressed.emit)
