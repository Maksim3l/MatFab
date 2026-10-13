class_name SimFixture extends RefCounted


# A sim over the real block defs with a 40x30 map centered on (0, 0) and no level loaded.
static func empty_sim() -> Simulation:
	return Simulation.new(Registry.buildings, Rect2i(Vector2i(-20, -15), Vector2i(40, 30)))


static func add_ore(sim: Simulation, value: int, cell: Vector2i, size: Vector2i) -> void:
	for y in size.y:
		for x in size.x:
			sim.ore[cell + Vector2i(x, y)] = value
