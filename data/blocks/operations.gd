class_name Operations extends RefCounted


func mine(ore: int) -> int:
	return ore


func sum(a: int, b: int) -> int:
	return a + b


func subtract(a: int, b: int) -> Variant:
	var difference := a - b
	return difference if difference > 0 else null


func multiply(a: int, b: int) -> int:
	return a * b
