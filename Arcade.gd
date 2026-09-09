extends Control


func _on_block_drop_button_pressed():
	var animation_player = $AnimationPlayer
	
	if not animation_player.has_animation("CRT_Zoom"):
		print("CRT_Zoom DOES NOT EXIST")
		print(animation_player.get_animation_list())
		return
	
	animation_player.play("CRT_Zoom")
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://BlockDrop/BlockDrop.tscn")


func _ready():
	resize_arcade()
	get_viewport().size_changed.connect(resize_arcade)


func resize_arcade():
	var viewport_size = get_viewport_rect().size
	
	# Actual visible CabinetArt size
	var art_size = Vector2(1024, 1536)
	var art_scale = 0.42
	
	var visible_size = art_size * art_scale
	
	# Fit the actual artwork to the available screen
	var scale_factor = min(
		viewport_size.x / visible_size.x,
		viewport_size.y / visible_size.y
	)
	
	# Leave a small border around the machine
	scale_factor *= 0.95
	
	# Scale the whole Cabinet
	$Cabinet.scale = Vector2(scale_factor, scale_factor)
	
	# Centre the visible CabinetArt
	var cabinet_art = $Cabinet/CabinetArt
	
	$Cabinet.position = Vector2(
		(viewport_size.x - visible_size.x * scale_factor) / 2.0
		- cabinet_art.position.x * scale_factor,
		(viewport_size.y - visible_size.y * scale_factor) / 2.0
		- cabinet_art.position.y * scale_factor
	)


func _on_delivery_boy_button_pressed() -> void:
	var animation_player = $AnimationPlayer
	
	if not animation_player.has_animation("CRT_Zoom"):
		print("CRT_Zoom DOES NOT EXIST")
		print(animation_player.get_animation_list())
		return
	
	animation_player.play("CRT_Zoom")
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://DeliveryBoy/DeliveryBoy.tscn")
	


func _on_worm_pressed() -> void:
	var animation_player = $AnimationPlayer
	
	if not animation_player.has_animation("CRT_Zoom"):
		print("CRT_Zoom DOES NOT EXIST")
		print(animation_player.get_animation_list())
		return
	
	animation_player.play("CRT_Zoom")
	
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://Worm/Sewers.tscn")
	
