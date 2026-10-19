extends GutTest


func test_every_screen_points_at_an_existing_scene() -> void:
	for id in Game.SCREENS:
		assert_true(ResourceLoader.exists(Game.SCREENS[id]), "%s: %s" % [id, Game.SCREENS[id]])
