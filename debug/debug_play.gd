extends Node

const LEVEL_ID := &"r1_01"

var sim: Simulation
var clock := SimClock.new()

@onready var world_view: WorldView = $WorldView


func _ready() -> void:
	sim = Simulation.from_level(Registry.levels[LEVEL_ID], Registry.buildings)
	world_view.show_sim(sim, clock)


func _process(delta: float) -> void:
	for step in clock.advance(delta):
		sim.step()
