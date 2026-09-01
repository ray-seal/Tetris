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

func _ready():
	resize_arcade()
	get_viewport().size_changed.connect(resize_arcade)


func resize_arcade():
	var viewport_size = get_viewport_rect().size
	
	var cabinet = $Cabinet
	var cabinet_size = Vector2(600, 900)
	
	# Scale the cabinet to fit the screen while keeping its proportions
	var scale_factor = min(
		viewport_size.x / cabinet_size.x,
		viewport_size.y / cabinet_size.y
	)
	
	scale_factor *= 0.95
	
	cabinet.scale = Vector2(scale_factor, scale_factor)
	
	# Centre the cabinet
	cabinet.position = Vector2(
		(viewport_size.x - cabinet_size.x * scale_factor) / 2.0,
		(viewport_size.y - cabinet_size.y * scale_factor) / 2.0
	)
