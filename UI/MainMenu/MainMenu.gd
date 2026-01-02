extends Control

## The main menu script is mainly for passing events up to other nodes
class_name MainMenu

signal play_button_pressed(ip: String, port: int)

func _on_play_button_pressed() -> void:
	emit_signal("play_button_pressed", "127.0.0.1", 8080)
