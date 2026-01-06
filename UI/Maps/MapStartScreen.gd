extends Control

## This is the screen that shows when you first join a map, where you can select
## a character model, loadout and spawn in
class_name MapStartScreen

## tell context that we are ready to spawn
signal spawn

func _ready():
	if not Util.running_as_server():
		emit_signal("spawn")

func _on_spawn_button_pressed() -> void:
	emit_signal("spawn")
