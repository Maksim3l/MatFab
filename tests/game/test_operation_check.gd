extends GutTest

const FOLDER := "res://tests/fixtures/operation_check/"


func problems_for(file_name: String) -> PackedStringArray:
	var defs: Array[BuildingDef] = [load(FOLDER + file_name + ".tres")]
	return OperationCheck.find_problems(defs)


func test_valid_def_passes() -> void:
	assert_eq(problems_for("valid_miner").size(), 0)


func test_missing_function_is_reported_with_its_path() -> void:
	var problems := problems_for("missing_operation")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], FOLDER + "missing_operation.tres")
	assert_string_contains(problems[0], "no_such_function")


func test_wrong_argument_count_is_reported() -> void:
	var problems := problems_for("wrong_argument_count")
	assert_eq(problems.size(), 1)
	assert_string_contains(problems[0], "takes 1 arguments but the def has 2 inputs")


func test_non_processor_defs_are_skipped() -> void:
	var conveyor := BuildingDef.new()
	conveyor.behavior = BuildingDef.Behavior.CONVEYOR
	var defs: Array[BuildingDef] = [conveyor]
	assert_eq(OperationCheck.find_problems(defs).size(), 0)
