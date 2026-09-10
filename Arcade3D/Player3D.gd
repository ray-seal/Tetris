extends CharacterBody3D

const SPEED = 5.0

var can_move := true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if can_move:
		# Left / Right Movement
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()
