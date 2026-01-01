extends Control

func _on_host_pressed() -> void:
	MultiplayerManager.host()
	visible = false


func _on_join_pressed() -> void:
	MultiplayerManager.join()
	visible = false
