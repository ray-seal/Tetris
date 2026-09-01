extends Control

func _on_block_drop_button_pressed():
	var animation_player = $AnimationPlayer
	
	if not animation_player.has_animation("CRT_Zoom"):
		print("CRT_Zoom DOES NOT EXIST")
		print(animation_player.get_animation_list())
		return
			
	animation_player.play("CRT_Zoom")
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://BlockDrop.tscn")
