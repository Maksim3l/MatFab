extends Node

const LEVEL_ID := &"r1_01"

var sim: Simulation
var clock := SimClock.new()

@onready var world_view: WorldView = $WorldView
@onready var hud: Hud = $UiLayer/Hud


func _ready() -> void:
	var level: LevelDef = Registry.levels[LEVEL_ID]
	sim = Simulation.from_level(level, Registry.buildings)
	world_view.show_sim(sim, clock, level.buildable)
	hud.show_goals(sim.tracker)
	hud.show_toolbar(world_view.build_tool)


func _process(delta: float) -> void:
	for step in clock.advance(delta):
		sim.step()
