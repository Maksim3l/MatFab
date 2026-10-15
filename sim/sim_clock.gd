class_name SimClock extends RefCounted

const STEPS_PER_SECOND := Simulation.TICKS_PER_SECOND
# Absorbs float error so sixty 1/60 s frames make exactly 20 steps.
const EPSILON := 0.000001

var _carried_seconds := 0.0


# Whole steps due after `delta` more seconds; the remainder carries to the next call.
func advance(delta: float) -> int:
	_carried_seconds += delta
	var steps := floori((_carried_seconds + EPSILON) * STEPS_PER_SECOND)
	_carried_seconds = maxf(_carried_seconds - float(steps) / STEPS_PER_SECOND, 0.0)
	return steps


# How far toward the next step, from 0 to 1, for drawing between ticks.
func fraction() -> float:
	return clampf(_carried_seconds * STEPS_PER_SECOND, 0.0, 1.0)
