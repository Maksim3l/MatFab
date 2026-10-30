extends Node

@onready var world_view: WorldView = $WorldView
@onready var hud: Hud = $UiLayer/Hud
@onready var action_bar: ActionBar = $UiLayer/ActionBar
@onready var pause_menu: PauseMenu = $UiLayer/PauseMenu
@onready var level_complete: LevelComplete = $UiLayer/LevelComplete


func _ready() -> void:
	world_view.show_sim(Game.sim, Game.clock, Game.level.buildable)
	hud.show_goals(Game.sim.tracker)
	hud.show_toolbar(world_view.build_tool)
	hud.pause_pressed.connect(pause)
	action_bar.show_tool(world_view.build_tool, Registry.controls_sorted)
	pause_menu.resume_pressed.connect(resume)
	pause_menu.main_menu_pressed.connect(Game.open.bind(&"main_menu"))
	pause_menu.settings_pressed.connect(Game.open.bind(&"settings"))
	level_complete.main_menu_pressed.connect(Game.open.bind(&"main_menu"))
	Game.level_completed.connect(level_complete.show)
	if Game.sim.tracker.is_complete():
		level_complete.show()
	elif Game.paused:
		pause_menu.show()


# Back drops the tool or selection first; with neither, it opens the pause menu, and from there resumes.
func go_back() -> void:
	if level_complete.visible:
		Game.open(&"main_menu")
	elif pause_menu.visible:
		resume()
	elif not world_view.build_tool.cancel():
		pause()


func pause() -> void:
	world_view.build_tool.cancel_gesture()
	Game.paused = true
	pause_menu.show()


func resume() -> void:
	Game.paused = false
	pause_menu.hide()
