extends CharacterBody3D

const SPEED = 5.0

@export var mouse_sensitivity := 0.002
@onready var camera: Camera3D = $Camera3D

var camera_pitch := 0.0
var can_move := true
var nearby_delivery: Node3D = null
var held_object: RigidBody3D = null
var controls_locked = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -1.5, 1.5)

func _physics_process(delta: float) -> void:
	camera.rotation.x = camera_pitch
	
	if controls_locked:
		velocity = Vector3.ZERO
		move_and_slide()
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	
	if Input.is_action_just_pressed("interact"):
		var target = $Camera3D/InteractionRay.get_collider()
		
		if target:
			print("Looking at: ", target.name)
			
			if target is RigidBody3D and target.is_in_group("delivery"):
					print("PICKING UP BOX!")
					
					if held_object != null:
						drop_object()
						
					pick_up_object(target)
					
					
	if can_move:
		# Left / Right Movement
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()
	
func pick_up_object(object: RigidBody3D) -> void:
	print("INSIDE PICK UP FUNCTION")
	
	if held_object != null:
		return
	
	held_object = object
	
	held_object.freeze = true
	
	held_object.reparent($Camera3D/HoldPoint, true)
	
	held_object.global_position = $Camera3D.global_position \
		+ (-$Camera3D.global_transform.basis.z * -4) \
		+ Vector3(1.5, -0.5, 0)
		
	held_object.global_rotation = $Camera3D.global_rotation
	
func drop_object() -> void:
	if held_object == null:
		return
		
	var object = held_object
	held_object = null
	
	object.reparent(get_tree().current_scene, true)
	object.freeze = false
	
	object.global_position = $Camera3D/HoldPoint.global_position
	


func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body == self:
		var deliveries = get_tree().get_nodes_in_group("delivery")
		if deliveries.size() > 0:
			var closest_delivery = deliveries[0]
			var closest_distance = global_position.distance_to(closest_delivery.global_position)
			
			for delivery in deliveries:
				var distance = global_position.distance_to(delivery.global_position)
				
				if distance < closest_distance:
					closest_delivery = delivery
					closest_distance = distance
					
				nearby_delivery = closest_delivery
				print("Player is near delivery box")
	
func _on_interaction_area_body_exited(body: Node3D) -> void:
	if body == self:
		nearby_delivery = null
		
		var deliveries = get_tree().get_nodes_in_group("deliveries")
		
		for delivery in deliveries:
			if delivery.visible:
				var distance = global_position.distance_to(delivery.global_position)
				
				if distance < 2.0:
					nearby_delivery = delivery
					break
					
		
		
	
	
