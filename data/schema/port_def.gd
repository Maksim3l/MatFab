class_name PortDef extends Resource

# Clockwise: rotation adds to this value, so reordering breaks every rotated port.
enum Side { UP, RIGHT, DOWN, LEFT }
enum Source { NEIGHBOR, ORE }

@export var cell := Vector2i.ZERO
@export var side := Side.DOWN
@export var source := Source.NEIGHBOR
