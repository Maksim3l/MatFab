extends GutTest


func test_pinch_zoom_scales_with_finger_distance() -> void:
	assert_almost_eq(GestureMath.pinch_zoom(1.0, 100.0, 200.0, 0.1, 10.0), 2.0, 0.0001)
	assert_almost_eq(GestureMath.pinch_zoom(2.0, 200.0, 100.0, 0.1, 10.0), 1.0, 0.0001)


func test_pinch_zoom_is_clamped() -> void:
	assert_eq(GestureMath.pinch_zoom(1.0, 100.0, 1000.0, 0.5, 2.0), 2.0)
	assert_eq(GestureMath.pinch_zoom(1.0, 100.0, 1.0, 0.5, 2.0), 0.5)


func test_zoom_keeps_the_point_under_the_fingers() -> void:
	var viewport := Vector2(1000, 600)
	var screen_point := Vector2(800, 100)
	var before := GestureMath.screen_to_world(Vector2(50, 50), 1.0, viewport, screen_point)
	var moved := GestureMath.position_after_zoom(Vector2(50, 50), 1.0, 2.0, viewport, screen_point)
	var after := GestureMath.screen_to_world(moved, 2.0, viewport, screen_point)
	assert_almost_eq(after.x, before.x, 0.001)
	assert_almost_eq(after.y, before.y, 0.001)
