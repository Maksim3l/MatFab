class_name TutorialStep extends Resource

# READ waits for the Naprej button; the others finish on their own once the player does what the text asks.
enum Goal { READ, SELECT, PLACE, DELIVER }

@export_multiline var text := ""
@export var goal := Goal.READ
# The block SELECT and PLACE wait for.
@export var block: BuildingDef
# How many of `block` PLACE waits for, or how many goal numbers DELIVER waits for.
@export var amount := 1
