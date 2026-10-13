extends GutTest

var sim: Simulation


func before_each() -> void:
	sim = SimFixture.sim_with_relay()


func steps(count: int) -> void:
	for i in count:
		sim.step()


func test_produces_the_result_after_duration_ticks() -> void:
	sim.place(&"relay", Vector2i(0, 0), 0)
	var relay := sim.building_at(Vector2i(0, 0))
	relay.inputs[0] = 4
	steps(9)
	assert_eq(relay.outputs[0], null)
	sim.step()
	assert_eq(relay.outputs[0], 4)
	assert_eq(relay.inputs[0], null)


func test_full_output_stops_the_timer() -> void:
	sim.place(&"relay", Vector2i(0, 0), 0)
	var relay := sim.building_at(Vector2i(0, 0))
	relay.outputs[0] = 1
	relay.inputs[0] = 4
	steps(30)
	assert_eq(relay.timer, 0)
	assert_eq(relay.outputs[0], 1)
	assert_eq(relay.inputs[0], 4)


func test_ore_input_stays_full_after_firing() -> void:
	SimFixture.add_ore(sim, 2, Vector2i(3, 3), Vector2i.ONE)
	sim.place(&"miner", Vector2i(3, 3), 0)
	var miner := sim.building_at(Vector2i(3, 3))
	steps(20)
	assert_eq(miner.outputs[0], 2)
	assert_eq(miner.inputs[0], 2)


func test_output_moves_to_the_next_processor_through_offer() -> void:
	sim.place(&"relay", Vector2i(0, 1), 0)
	sim.place(&"relay", Vector2i(0, 0), 0)
	var lower := sim.building_at(Vector2i(0, 1))
	var upper := sim.building_at(Vector2i(0, 0))
	lower.inputs[0] = 5
	steps(10)
	assert_eq(lower.outputs[0], null)
	assert_eq(upper.inputs[0], 5)


func test_input_refuses_a_number_from_the_wrong_side() -> void:
	sim.place(&"relay", Vector2i(0, 0), 0)
	assert_false(sim.offer(Vector2i(-1, 0), PortDef.Side.RIGHT, 3))
	assert_true(sim.offer(Vector2i(0, 1), PortDef.Side.UP, 3))
