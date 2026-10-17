class_name TouchGestures extends Node

const WHEEL_ZOOM_STEP := 1.1

@export var camera_rig: CameraRig

var touches: Dictionary[int, Vector2] = {}
var pinch_start_distance := 0.0
var pinch_start_zoom := 1.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
	elif event is InputEventMouseButton and event.pressed:
		handle_wheel(event)


func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		touches[event.index] = event.position
	else:
		touches.erase(event.index)
	if touches.size() == 2:
		begin_pinch()
	get_viewport().set_input_as_handled()


func handle_drag(event: InputEventScreenDrag) -> void:
	if not touches.has(event.index):
		return
	touches[event.index] = event.position
	if touches.size() == 1:
		camera_rig.pan_by_screen(event.relative)
	elif touches.size() == 2:
		pan_and_pinch(event.relative)
	get_viewport().set_input_as_handled()


func pan_and_pinch(relative: Vector2) -> void:
	camera_rig.pan_by_screen(relative * 0.5)
	var points := touches.values()
	var pinched := GestureMath.pinch_zoom(pinch_start_zoom, pinch_start_distance, points[0].distance_to(points[1]), CameraRig.MIN_ZOOM, CameraRig.MAX_ZOOM)
	camera_rig.zoom_to(pinched, (points[0] + points[1]) * 0.5)


func handle_wheel(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera_rig.zoom_to(camera_rig.zoom_level() * WHEEL_ZOOM_STEP, event.position)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera_rig.zoom_to(camera_rig.zoom_level() / WHEEL_ZOOM_STEP, event.position)


func begin_pinch() -> void:
	var points := touches.values()
	pinch_start_distance = points[0].distance_to(points[1])
	pinch_start_zoom = camera_rig.zoom_level()
