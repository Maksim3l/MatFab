class_name AutosaveTimer extends RefCounted

const INTERVAL_SECONDS := 30.0
# Absorbs float error so thirty seconds of 1/60 s frames count as thirty seconds.
const EPSILON := 0.000001

var _elapsed := 0.0


# True once every 30 seconds of play; the time past the interval carries over.
func advance(delta: float) -> bool:
	_elapsed += delta
	if _elapsed + EPSILON < INTERVAL_SECONDS:
		return false
	_elapsed -= INTERVAL_SECONDS
	return true


func restart() -> void:
	_elapsed = 0.0
