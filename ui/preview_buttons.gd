class_name PreviewButtons extends Control

const BUTTON_SIZE := Vector2(76, 76)
const GAP := 12.0
# Space kept between the buttons and the top edge of the preview.
const LIFT := 14.0
const EDGE_MARGIN := 8.0
# Screen strips taken by the action bar on the right and the toolbar at the bottom; the buttons stay out of them.
const RIGHT_RESERVED := 200.0
const BOTTOM_RESERVED := 124.0

var build_tool: BuildTool
var camera_rig: CameraRig

@onready var rotate_button: Button = $Row/RotateButton
@onready var place_button: Button = $Row/PlaceButton
@onready var row: HBoxContainer = $Row


func show_tool(tool: BuildTool, camera: CameraRig) -> void:
	build_tool = tool
	camera_rig = camera
	rotate_button.pressed.connect(build_tool.rotate_cw)
	place_button.pressed.connect(build_tool.place_preview)


# Follows the preview every frame: centered above it, kept on screen, hidden while a drag runs.
func _process(_delta: float) -> void:
	var shown := build_tool != null and build_tool.has_preview() and not (build_tool.gesture_active and build_tool.drag_cells.size() > 1)
	row.visible = shown
	if not shown:
		return
	place_button.disabled = not build_tool.preview_fits()
	var bounds := preview_bounds()
	var top_center := camera_rig.world_to_screen(Vector2(bounds.get_center().x, bounds.position.y))
	var size_needed := Vector2(BUTTON_SIZE.x * 2 + GAP, BUTTON_SIZE.y)
	var corner := top_center - Vector2(size_needed.x * 0.5, size_needed.y + LIFT)
	var screen := get_viewport_rect().size
	if corner.y < EDGE_MARGIN:
		var bottom_center := camera_rig.world_to_screen(Vector2(bounds.get_center().x, bounds.end.y))
		corner.y = bottom_center.y + LIFT
	corner.x = clampf(corner.x, EDGE_MARGIN, screen.x - RIGHT_RESERVED - size_needed.x)
	corner.y = clampf(corner.y, EDGE_MARGIN, screen.y - BOTTOM_RESERVED - size_needed.y)
	row.position = corner


func preview_bounds() -> Rect2:
	var bounds := Rect2()
	var first := true
	for placement in build_tool.preview_placements():
		var footprint := Ports.rotated_size(build_tool.sim.defs[placement.def_id].size, placement.rotation)
		var rect := Grid.cells_rect(placement.origin, footprint)
		bounds = rect if first else bounds.merge(rect)
		first = false
	return bounds
