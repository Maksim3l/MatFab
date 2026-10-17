class_name WorldView extends Node2D

var sim: Simulation
var clock: SimClock

@onready var ground_view: GroundView = $GroundView
@onready var building_view: BuildingView = $BuildingView
@onready var camera_rig: CameraRig = $CameraRig


func show_sim(simulation: Simulation, sim_clock: SimClock) -> void:
	sim = simulation
	clock = sim_clock
	ground_view.show_sim(sim)
	building_view.show_sim(sim)
	center_camera()


func center_camera() -> void:
	var mothership := sim.building_at(Vector2i.ZERO)
	camera_rig.center_on(Grid.cells_rect(mothership.origin, mothership.size()).get_center())
