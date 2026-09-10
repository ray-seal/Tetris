extends CanvasLayer

func _on_replay_button_pressed():
	get_tree().reload_current_scene()
	print("Button works")


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_back_to_arcade_pressed() -> void:
	get_tree().change_scene_to_file("res://Arcade.tscn")
