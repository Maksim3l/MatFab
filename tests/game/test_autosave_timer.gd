extends GutTest


func test_fires_every_30_seconds() -> void:
	var timer := AutosaveTimer.new()
	var fired := 0
	for frame in 60 * 90:
		if timer.advance(1.0 / 60.0):
			fired += 1
	assert_eq(fired, 3)


func test_does_not_fire_before_30_seconds() -> void:
	var timer := AutosaveTimer.new()
	assert_false(timer.advance(29.9))
	assert_true(timer.advance(0.2))
	assert_false(timer.advance(0.2))


func test_restart_starts_the_interval_over() -> void:
	var timer := AutosaveTimer.new()
	timer.advance(25.0)
	timer.restart()
	assert_false(timer.advance(10.0))
