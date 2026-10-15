class_name OperationCheck extends RefCounted


# One message per PROCESSOR def whose operation is missing from Operations or takes a different number of arguments than the def has inputs.
static func find_problems(defs: Array[BuildingDef]) -> PackedStringArray:
	var operations := Operations.new()
	var problems := PackedStringArray()
	for def in defs:
		if def.behavior != BuildingDef.Behavior.PROCESSOR:
			continue
		if not operations.has_method(def.operation):
			problems.append("%s: operations.gd has no function %s" % [def.resource_path, def.operation])
			continue
		var argument_count := operations.get_method_argument_count(def.operation)
		if argument_count != def.inputs.size():
			problems.append("%s: %s takes %d arguments but the def has %d inputs" % [def.resource_path, def.operation, argument_count, def.inputs.size()])
	return problems
