extends CharacterBody3D

const SPEED = 5.0

@export var mouse_sensitivity := 0.002
@onready var camera: Camera3D = $Camera3D

var camera_pitch := 0.0
var can_move := true
var nearby_delivery: Node3D = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, 1.5, 1.5)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("interact") and nearby_delivery:
		nearby_delivery.visible = false
		nearby_delivery = null
		
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


func _on_interaction_area_body_entered(body: Node3D) -> void:
	if body == self:
		var deliveries = get_tree().get_nodes_in_group("delivery")
		if deliveries.size > 0:
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
		
	
	
