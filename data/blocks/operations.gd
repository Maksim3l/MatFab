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


func divide(a: int, b: int) -> Variant:
	if b == 0 or a % b != 0:
		return null
	@warning_ignore("integer_division")
	return a / b
