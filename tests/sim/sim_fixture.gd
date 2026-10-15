class_name SimFixture extends RefCounted


# A sim over the real block defs with a 40x30 map centered on (0, 0) and no level loaded.
static func empty_sim() -> Simulation:
	return Simulation.new(Registry.buildings, Rect2i(Vector2i(-20, -15), Vector2i(40, 30)))


static func add_ore(sim: Simulation, value: int, cell: Vector2i, size: Vector2i) -> void:
	for y in size.y:
		for x in size.x:
			sim.ore[cell + Vector2i(x, y)] = value


# Passes its one input, entering from below, to its output on top after 0.5 s.
static func relay_def() -> BuildingDef:
	var def := BuildingDef.new()
	def.id = &"relay"
	var input := PortDef.new()
	input.side = PortDef.Side.DOWN
	def.inputs.append(input)
	var output := PortDef.new()
	output.side = PortDef.Side.UP
	def.outputs.append(output)
	def.operation = &"mine"
	def.duration = 0.5
	return def


static func sim_with_relay() -> Simulation:
	var defs := Registry.buildings.duplicate()
	defs[&"relay"] = relay_def()
	return Simulation.new(defs, Rect2i(Vector2i(-20, -15), Vector2i(40, 30)))
