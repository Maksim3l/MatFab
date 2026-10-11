extends GutTest


func test_mine_returns_the_ore_value() -> void:
	assert_eq(Operations.new().mine(3), 3)
