class_name ActionButtonFilter extends RefCounted


# The defs to show, in the order given (file-name order), for the contexts that are active right now.
static func visible_defs(defs: Array[ActionButtonDef], active: Array[ActionButtonDef.Context]) -> Array[ActionButtonDef]:
	var shown: Array[ActionButtonDef] = []
	for def in defs:
		for context in def.shown_with:
			if context == ActionButtonDef.Context.ALWAYS or active.has(context):
				shown.append(def)
				break
	return shown
