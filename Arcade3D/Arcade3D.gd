extends Node3D

var player_near_blockdrop := false
var player_near_deliveryboy := false

func _on_blockdrop_area_body_entered(body: Node3D) -> void:
	if body.name == "Player3D":
		player_near_blockdrop = true
		
func _on_blockdrop_area_body_exited(body: Node3D):
	if body.name == "Player3D":
		player_near_blockdrop = false
		
func _on_deliveryboy_area_body_entered(body: Node3D) -> void:
	if body.name == "Player3D":
		player_near_deliveryboy = true
		
func _on_deliveryboy_area_body_exited(body: Node3D):
	if body.name == "Player3D":
		player_near_deliveryboy = false
		
func _input(event):
	if event is InputEventKey and event.pressed:
		
		if player_near_blockdrop:
			if event.keycode == KEY_SPACE or event.keycode == KEY_Q:
				get_tree().change_scene_to_file("res://BlockDrop/BlockDrop.tscn")
				
		if player_near_deliveryboy:
			if event.keycode == KEY_SPACE or event.keycode == KEY_Q:
				get_tree().change_scene_to_file("res://DeliveryBoy/DeliveryBoy.tscn")
				
