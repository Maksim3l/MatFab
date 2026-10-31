class_name LevelGroups extends RefCounted


# Levels under each grade, grades ascending; each grade keeps the order it was given (file-name order).
static func by_grade(levels: Array[LevelDef]) -> Dictionary[int, Array]:
	var groups: Dictionary[int, Array] = {}
	for level in levels:
		if not groups.has(level.grade):
			groups[level.grade] = []
		groups[level.grade].append(level)
	groups.sort()
	return groups


# Grade 0 holds the tutorial level, which comes before every grade.
static func grade_title(grade: int) -> String:
	return "Navodila" if grade == 0 else "%d. razred" % grade
