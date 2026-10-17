class_name GestureMath extends RefCounted


# The zoom at the start of a pinch, scaled by how far the two fingers have spread since.
static func pinch_zoom(start_zoom: float, start_distance: float, distance: float, min_zoom: float, max_zoom: float) -> float:
	if start_distance <= 0.0:
		return start_zoom
	return clampf(start_zoom * distance / start_distance, min_zoom, max_zoom)


# World point under a screen point for a centered, unrotated camera.
static func screen_to_world(camera_position: Vector2, zoom: float, viewport_size: Vector2, screen_point: Vector2) -> Vector2:
	return camera_position + (screen_point - viewport_size * 0.5) / zoom


# Camera position after a zoom change that keeps the world point under `screen_point` in place.
static func position_after_zoom(camera_position: Vector2, old_zoom: float, new_zoom: float, viewport_size: Vector2, screen_point: Vector2) -> Vector2:
	var anchor := screen_to_world(camera_position, old_zoom, viewport_size, screen_point)
	return anchor - (screen_point - viewport_size * 0.5) / new_zoom
