class_name GhostView extends BuildingView

const GHOST_ALPHA := 0.6
const BLOCKED_TINT := Color(1.0, 0.35, 0.35)
const ERASE_COLOR := Color(1.0, 0.2, 0.2, 0.45)
const SELECTION_FILL := Color(0.35, 0.65, 1.0, 0.18)
const SELECTION_BORDER := Color(0.45, 0.75, 1.0, 0.9)

var build_tool: BuildTool


func show_tool(tool: BuildTool) -> void:
	build_tool = tool


func _draw() -> void:
	if build_tool == null:
		return
	if build_tool.has_selection():
		var rect := Grid.cells_rect(build_tool.selection.position, build_tool.selection.size)
		draw_rect(rect, SELECTION_FILL)
		draw_rect(rect, SELECTION_BORDER, false, 3.0)
	for building in build_tool.erase_marks:
		draw_rect(Grid.cells_rect(building.origin, building.size()), ERASE_COLOR)
	var ghosts := build_tool.ghosts
	for i in ghosts.size():
		var ghost := ghosts[i]
		var tint := Color.WHITE if build_tool.ghost_fits(ghost) else BLOCKED_TINT
		var def: BuildingDef = build_tool.sim.defs[ghost.def_id]
		if def.behavior == BuildingDef.Behavior.CONVEYOR:
			draw_conveyor(ghost.origin, ghost_input_side(ghosts, i), ghost.rotation, GHOST_ALPHA, tint)
		else:
			draw_placeholder(def, ghost.origin, ghost.rotation, GHOST_ALPHA, tint)


# A conveyor ghost is drawn fed from the ghost before it, which makes the corners of a drag visible.
func ghost_input_side(ghosts: Array[Placement], index: int) -> int:
	var front := Ports.rotate_side(PortDef.Side.UP, ghosts[index].rotation)
	if index > 0:
		var side := Ports.side_toward(ghosts[index].origin, ghosts[index - 1].origin)
		if side != -1 and side != front:
			return side
	return Ports.opposite_side(front)
