class_name WorldView extends Node2D

var sim: Simulation
var clock: SimClock

@onready var ground_view: GroundView = $GroundView
@onready var building_view: BuildingView = $BuildingView
@onready var item_view: ItemView = $ItemView
@onready var ghost_view: GhostView = $GhostView
@onready var camera_rig: CameraRig = $CameraRig
@onready var build_tool: BuildTool = $BuildTool


func show_sim(simulation: Simulation, sim_clock: SimClock, buildable: Array[BuildingDef]) -> void:
	sim = simulation
	clock = sim_clock
	ground_view.show_sim(sim)
	building_view.show_sim(sim)
	item_view.show_sim(sim, clock)
	build_tool.show_sim(sim, buildable)
	ghost_view.show_tool(build_tool)
	build_tool.center_camera()
