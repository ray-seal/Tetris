extends CanvasLayer

func _on_replay_button_pressed():
	get_tree().reload_current_scene()
	print("Button works")


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()
