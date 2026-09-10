extends Node3D

var player_near_machine := false

func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body.name == "Player3D":
		player_near_machine = true
		
func _on_interaction_area_body_exited(body: Node3D):
	if body.name == "Player3D":
		player_near_machine = false
		
func _input(event):
	if player_near_machine and event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_Q:
			get_tree().change_scene_to_file("res://BlockDrop/BlockDrop.tscn")
			
			
