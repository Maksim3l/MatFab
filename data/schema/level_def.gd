class_name LevelDef extends Resource

@export var title := ""
@export var grade := 1
@export var map_size := Vector2i(40, 30)
@export var ore_patches: Array[OrePatch] = []
@export var goals: Dictionary[int, int] = {}
@export var buildable: Array[BuildingDef] = []

# Progress and world saves store this id; renaming the .tres loses that level's progress and save.
var id: StringName
