extends Node

signal level_completed

const SCREENS: Dictionary[StringName, String] = {
	&"main_menu": "res://ui/main_menu.tscn",
	&"level_select": "res://ui/level_select.tscn",
	&"settings": "res://ui/settings_menu.tscn",
	&"play": "res://game/play.tscn",
}

var level: LevelDef
var sim: Simulation
var clock := SimClock.new()
var paused := false
# Filled from progress.sav by the save store; level select marks these levels.
var completed_levels: Array[StringName] = []
var last_played := &""
var save_store := SaveStore.new()
var autosave := AutosaveTimer.new()
# Blocks whose description the HUD has already shown once; the Info window shows them again.
var seen_block_info: Array[StringName] = []


func _ready() -> void:
	# Keeps running while the tree is paused, so back still reaches go_back.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var progress := save_store.load_progress()
	completed_levels.assign(progress["completed"])
	last_played = progress["last_played"]


func _physics_process(delta: float) -> void:
	step_sim(delta)


func step_sim(delta: float) -> void:
	if sim == null or paused:
		return
	for step in clock.advance(delta):
		sim.step()
	if autosave.advance(delta):
		save_world()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		go_back()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		save_world()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		go_back()


# Leaving to the menus ends the level; the settings screen keeps it, so back returns to it paused.
func open(id: StringName) -> void:
	if id == &"main_menu" or id == &"level_select":
		close_level()
	get_tree().change_scene_to_file(SCREENS[id])


func open_level(level_def: LevelDef) -> void:
	level = level_def
	sim = Simulation.from_level(level, Registry.buildings)
	if save_store.has_world(level.id):
		save_store.load_world(level.id, sim)
	clock = SimClock.new()
	autosave.restart()
	paused = false
	sim.tracker.completed.connect(complete_level)
	last_played = level.id
	save_progress()
	open(&"play")


# The level played last, when it still exists; Nadaljuj opens it.
func continue_level() -> LevelDef:
	return Registry.levels.get(last_played)


func complete_level() -> void:
	if not completed_levels.has(level.id):
		completed_levels.append(level.id)
	paused = true
	save_world()
	save_progress()
	level_completed.emit()


func save_world() -> void:
	if sim != null:
		save_store.save_world(level.id, sim)


func save_progress() -> void:
	save_store.save_progress(completed_levels, last_played)


func close_level() -> void:
	save_world()
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
		&"play", &"settings":
			get_tree().current_scene.go_back()


func current_screen() -> StringName:
	var scene := get_tree().current_scene
	var id: Variant = SCREENS.find_key(scene.scene_file_path) if scene else null
	return id if id != null else &""
