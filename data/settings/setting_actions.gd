class_name SettingActions extends RefCounted

# One function per SettingDef.action; each receives the stored float.


func master_volume(value: float) -> void:
	set_bus_volume(&"Master", value)


func music_volume(value: float) -> void:
	set_bus_volume(&"Music", value)


func effects_volume(value: float) -> void:
	set_bus_volume(&"SFX", value)


static func set_bus_volume(bus_name: StringName, value: float) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	if bus == -1:
		return
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	AudioServer.set_bus_mute(bus, value <= 0.0)
