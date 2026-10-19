extends GutTest


func _level(id: StringName, grade: int) -> LevelDef:
	var level := LevelDef.new()
	level.id = id
	level.grade = grade
	return level


func _ids(levels: Array) -> Array[StringName]:
	var ids: Array[StringName] = []
	for level: LevelDef in levels:
		ids.append(level.id)
	return ids


func test_grades_come_out_ascending() -> void:
	var levels: Array[LevelDef] = [_level(&"r2_01", 2), _level(&"r1_01", 1), _level(&"r3_01", 3)]
	assert_eq(LevelGroups.by_grade(levels).keys(), [1, 2, 3])


func test_each_grade_keeps_file_name_order() -> void:
	var levels: Array[LevelDef] = [
		_level(&"r1_01", 1), _level(&"r2_01", 2), _level(&"r1_02", 1), _level(&"r1_03", 1),
	]
	var groups := LevelGroups.by_grade(levels)
	assert_eq(_ids(groups[1]), [&"r1_01", &"r1_02", &"r1_03"] as Array[StringName])
	assert_eq(_ids(groups[2]), [&"r2_01"] as Array[StringName])


func test_no_levels_give_no_groups() -> void:
	var levels: Array[LevelDef] = []
	assert_true(LevelGroups.by_grade(levels).is_empty())


func test_grade_title() -> void:
	assert_eq(LevelGroups.grade_title(1), "1. razred")
