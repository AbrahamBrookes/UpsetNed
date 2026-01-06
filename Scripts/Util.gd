extends Node

## A dumbing ground for utility functions - autoloaded as "Util"

## A helper to grab a launch arg by key
func get_launch_arg(key: String, default: String = "") -> String:
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--%s=" % key):
			return arg.split("=", false, 1)[1]
	return default

# a helper to isolate the logic we use to check if we are a server
func running_as_server() -> bool:
	#return display_server_provider.get_name() == "headless"
	return get_launch_arg("mode") == "server"
