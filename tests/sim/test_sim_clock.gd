extends GutTest


func test_deltas_summing_to_one_second_give_20_steps() -> void:
	var clock := SimClock.new()
	var steps := 0
	for frame in 60:
		steps += clock.advance(1.0 / 60.0)
	assert_eq(steps, 20)


func test_remainder_carries_across_calls() -> void:
	var clock := SimClock.new()
	assert_eq(clock.advance(0.03), 0)
	assert_almost_eq(clock.fraction(), 0.6, 0.001)
	assert_eq(clock.advance(0.03), 1)
	assert_almost_eq(clock.fraction(), 0.2, 0.001)


func test_a_long_frame_gives_several_steps() -> void:
	var clock := SimClock.new()
	assert_eq(clock.advance(0.26), 5)
