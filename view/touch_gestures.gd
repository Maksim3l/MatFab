class_name TouchGestures extends Node

const WHEEL_ZOOM_STEP := 1.1
const LONG_PRESS_MSEC := 500
# How far a finger may drift and still count as held still for a long press.
const LONG_PRESS_SLOP := 18.0

@export var camera_rig: CameraRig
@export var build_tool: BuildTool

var touches: Dictionary[int, Vector2] = {}
var pinch_start_distance := 0.0
var pinch_start_zoom := 1.0
# Set when a second finger cancels the first finger's ghosts; nothing places until every finger lifts.
var gesture_cancelled := false
var press_started_msec := -1
var press_position := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)
	elif event is InputEventMouseButton and event.pressed:
		handle_wheel(event)


func _process(_delta: float) -> void:
	if press_started_msec >= 0 and Time.get_ticks_msec() - press_started_msec >= LONG_PRESS_MSEC:
		press_started_msec = -1
		long_press(press_position)


# A long press picks up a tool; the release after it places nothing.
func long_press(screen_point: Vector2) -> void:
	build_tool.cancel_gesture()
	gesture_cancelled = true
	build_tool.pipette_at(cell_at(screen_point))


func cell_at(screen_point: Vector2) -> Vector2i:
	return Grid.world_to_cell(camera_rig.screen_to_world(screen_point))


func handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		touches[event.index] = event.position
		if touches.size() == 1:
			press_started_msec = Time.get_ticks_msec()
			press_position = event.position
			build_tool.press(cell_at(event.position))
		elif touches.size() == 2:
			press_started_msec = -1
			build_tool.cancel_gesture()
			gesture_cancelled = true
			begin_pinch()
	else:
		touches.erase(event.index)
		press_started_msec = -1
		if touches.is_empty():
			if not gesture_cancelled:
				build_tool.release()
			gesture_cancelled = false
	get_viewport().set_input_as_handled()


func handle_drag(event: InputEventScreenDrag) -> void:
	if not touches.has(event.index):
		return
	touches[event.index] = event.position
	if event.position.distance_to(press_position) > LONG_PRESS_SLOP:
		press_started_msec = -1
	if touches.size() == 2:
		pan_and_pinch(event.relative)
	elif build_tool.gesture_active:
		build_tool.drag_to(cell_at(event.position))
	else:
		camera_rig.pan_by_screen(event.relative)
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
