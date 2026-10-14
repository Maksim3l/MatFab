class_name CameraRig extends Camera2D

const MIN_ZOOM := 0.35
const MAX_ZOOM := 2.5


func zoom_level() -> float:
	return zoom.x


func pan_by_screen(screen_delta: Vector2) -> void:
	position -= screen_delta / zoom_level()


func zoom_to(new_zoom: float, screen_point: Vector2) -> void:
	var clamped := clampf(new_zoom, MIN_ZOOM, MAX_ZOOM)
	position = GestureMath.position_after_zoom(position, zoom_level(), clamped, get_viewport_rect().size, screen_point)
	zoom = Vector2.ONE * clamped


func center_on(world_point: Vector2) -> void:
	position = world_point


func screen_to_world(screen_point: Vector2) -> Vector2:
	return GestureMath.screen_to_world(position, zoom_level(), get_viewport_rect().size, screen_point)
