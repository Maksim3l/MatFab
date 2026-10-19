extends Node

@onready var world_view: WorldView = $WorldView
@onready var hud: Hud = $UiLayer/Hud


func _ready() -> void:
	world_view.show_sim(Game.sim, Game.clock)
	hud.show_goals(Game.sim.tracker)
