extends Node

# no class name so it doesn't conflict - named in autoload

var invert_y: bool = true

func toggle_invert_y():
	invert_y = !invert_y
	save()

func save():
	var cfg := ConfigFile.new()
	cfg.set_value("controls", "invert_y", invert_y)
	cfg.save("user://settings.cfg")

func load_settings():
	var cfg := ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		invert_y = cfg.get_value("controls", "invert_y", false)
