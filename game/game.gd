extends Node

signal level_completed

const SCREENS: Dictionary[StringName, String] = {
	&"main_menu": "res://ui/main_menu.tscn",
	&"level_select": "res://ui/level_select.tscn",
	&"play": "res://game/play.tscn",
}

var level: LevelDef
var sim: Simulation
var clock := SimClock.new()
var paused := false
# Filled from progress.sav by the save store; level select marks these levels.
var completed_levels: Array[StringName] = []


func _ready() -> void:
	# Keeps running while the tree is paused, so back still reaches go_back.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(delta: float) -> void:
	step_sim(delta)


func step_sim(delta: float) -> void:
	if sim == null or paused:
		return
	for step in clock.advance(delta):
		sim.step()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		go_back()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		go_back()


func open(id: StringName) -> void:
	if id != &"play":
		close_level()
	get_tree().change_scene_to_file(SCREENS[id])


func open_level(level_def: LevelDef) -> void:
	level = level_def
	sim = Simulation.from_level(level, Registry.buildings)
	clock = SimClock.new()
	paused = false
	sim.tracker.completed.connect(complete_level)
	open(&"play")


func complete_level() -> void:
	if not completed_levels.has(level.id):
		completed_levels.append(level.id)
	paused = true
	level_completed.emit()


func close_level() -> void:
	level = null
	sim = null
	paused = false


# On the play screen back is the screen's own: it drops the tool or selection first, then opens the pause menu.
func go_back() -> void:
	match current_screen():
		&"main_menu":
			get_tree().quit()
		&"level_select":
			open(&"main_menu")
		&"play":
			get_tree().current_scene.go_back()


func current_screen() -> StringName:
	var scene := get_tree().current_scene
	var id: Variant = SCREENS.find_key(scene.scene_file_path) if scene else null
	return id if id != null else &""
