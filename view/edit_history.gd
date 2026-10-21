class_name EditHistory extends RefCounted

# One entry per gesture (tap, drag, paste, delete): {"added": Array[Placement], "removed": Array[Placement]}.
var undo_entries: Array[Dictionary] = []
var redo_entries: Array[Dictionary] = []


func record(added: Array[Placement], removed: Array[Placement]) -> void:
	if added.is_empty() and removed.is_empty():
		return
	undo_entries.append({"added": added, "removed": removed})
	redo_entries.clear()


func can_undo() -> bool:
	return not undo_entries.is_empty()


func can_redo() -> bool:
	return not redo_entries.is_empty()


func undo(sim: Simulation) -> bool:
	if undo_entries.is_empty():
		return false
	var entry: Dictionary = undo_entries.pop_back()
	swap(sim, entry["added"], entry["removed"])
	redo_entries.append(entry)
	return true


func redo(sim: Simulation) -> bool:
	if redo_entries.is_empty():
		return false
	var entry: Dictionary = redo_entries.pop_back()
	swap(sim, entry["removed"], entry["added"])
	undo_entries.append(entry)
	return true


# Removes `take_away` and places `put_back` through the sim's own commands.
static func swap(sim: Simulation, take_away: Array[Placement], put_back: Array[Placement]) -> void:
	for i in range(take_away.size() - 1, -1, -1):
		sim.remove(take_away[i].origin)
	for placement in put_back:
		sim.place(placement.def_id, placement.origin, placement.rotation)
