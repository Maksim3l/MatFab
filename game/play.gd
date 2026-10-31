extends Node

@onready var world_view: WorldView = $WorldView
@onready var hud: Hud = $UiLayer/Hud
@onready var action_bar: ActionBar = $UiLayer/ActionBar
@onready var pause_menu: PauseMenu = $UiLayer/PauseMenu
@onready var level_complete: LevelComplete = $UiLayer/LevelComplete
@onready var tutorial_panel: TutorialPanel = $UiLayer/TutorialPanel
@onready var block_info_menu: BlockInfoMenu = $UiLayer/BlockInfoMenu


func _ready() -> void:
	world_view.show_sim(Game.sim, Game.clock, Game.level.buildable)
	hud.show_goals(Game.sim.tracker)
	hud.show_toolbar(world_view.build_tool)
	hud.pause_pressed.connect(pause)
	hud.info_pressed.connect(open_info)
	block_info_menu.close_pressed.connect(close_info)
	action_bar.show_tool(world_view.build_tool, Registry.controls_sorted)
	pause_menu.resume_pressed.connect(resume)
	pause_menu.main_menu_pressed.connect(Game.open.bind(&"main_menu"))
	pause_menu.settings_pressed.connect(Game.open.bind(&"settings"))
	level_complete.main_menu_pressed.connect(Game.open.bind(&"main_menu"))
	Game.level_completed.connect(level_complete.show)
	Game.level_completed.connect(tutorial_panel.hide)
	# The tutorial starts over on every visit; Preskoči hides it.
	tutorial_panel.show_tutorial(Game.level.tutorial, Game.sim, world_view.build_tool)
	if Game.sim.tracker.is_complete():
		level_complete.show()
	elif Game.paused:
		pause_menu.show()


# Back drops the tool or selection first; with neither, it opens the pause menu, and from there resumes.
func go_back() -> void:
	if level_complete.visible:
		Game.open(&"main_menu")
	elif block_info_menu.visible:
		close_info()
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


# The Info window lists the mothership and every block the level offers; the sim waits while it is open.
func open_info() -> void:
	world_view.build_tool.cancel_gesture()
	Game.paused = true
	var defs: Array[BuildingDef] = [Registry.buildings[&"mothership"]]
	defs.append_array(Game.level.buildable)
	block_info_menu.show_blocks(defs)


func close_info() -> void:
	Game.paused = false
	block_info_menu.hide()
