extends Node2D

@export var speed := 250.0
@export var circle_speed := 2.5
@export var circle_radius := 100.0

var player
var circling := false
var circle_angle := 0.0
var circles_remaining := 0.0
var circle_progress := 0.0
var current_circle_radius := 100.0

var stopping := false
var parked := false

var target_position := Vector2.ZERO


func _ready():
	$AnimatedSprite2D.play("ChavUp")


func _process(delta):

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return


	# --------------------------------
	# APPROACH PLAYER FROM BELOW
	# --------------------------------

	if not circling and not stopping and not parked:

		var movement = Vector2(0, -speed * delta)
		position += movement

		$AnimatedSprite2D.play("ChavUp")

		# Start circling when we're close to the player
		if position.y <= player.global_position.y + 150:
			start_circling()

		return


	# --------------------------------
	# CIRCLE PLAYER
	# --------------------------------

	if circling:

		circle_player(delta)

		return


	# --------------------------------
	# TRAVEL TO FINAL POSITION
	# --------------------------------

	if stopping:

		var distance = global_position.distance_to(target_position)

		if distance > 5.0:

			var direction = global_position.direction_to(target_position)
			var movement = direction * speed * delta

			# Don't overshoot the target
			if movement.length() > distance:
				movement = direction * distance

			global_position += movement

			update_animation(movement)

		else:

			global_position = target_position
			stopping = false
			parked = true

			$AnimatedSprite2D.play("ChavUp")

			print("CHAV STOPPED IN PLAYER'S LANE")

		return


	# --------------------------------
	# PARKED OBSTACLE
	# --------------------------------

	if parked:

		# Road scrolls downward
		var movement = Vector2(0, 150.0 * delta)

		global_position += movement

		$AnimatedSprite2D.play("ChavDown")

		# Despawn once he leaves the screen
		var screen_height = get_viewport_rect().size.y

		if global_position.y > screen_height + 150:
			print("CHAV LEFT SCREEN - DESPAWNING")
			queue_free()

		return
		
func start_circling():

	circling = true

	# Start the circle from the Chav's CURRENT position
	var offset = global_position - player.global_position

	circle_angle = atan2(offset.y, offset.x)

	# Remember actual distance from player
	current_circle_radius = offset.length()

	circle_progress = 0.0

	# Randomly circle between 1 and 3 times
	circles_remaining = randf_range(1.0, 3.0)

	print(
		"CHAV CIRCLING! Circles: ",
		circles_remaining,
		" Starting radius: ",
		current_circle_radius
	)


func circle_player(delta):

	var old_position = global_position

	var angle_change = circle_speed * delta

	circle_angle += angle_change
	circle_progress += angle_change

	# Smoothly bring radius toward normal radius
	current_circle_radius = move_toward(
		current_circle_radius,
		circle_radius,
		200.0 * delta
	)

	var target_position_circle = player.global_position

	global_position = target_position_circle + Vector2(
		cos(circle_angle),
		sin(circle_angle)
	) * current_circle_radius

	var movement = global_position - old_position

	update_animation(movement)


	# --------------------------------
	# FINISH CIRCLE ONLY WHEN ABOVE PLAYER
	# --------------------------------

	if circle_progress >= TAU * circles_remaining:

		# Don't leave the circle while we're below
		# or level with the player.
		if global_position.y < player.global_position.y - 30:

			circling = false
			start_final_position()


func start_final_position():

	# Player's current lane
	var player_lane = player.current_lane

	# Stay in the player's current lane
	var target_x = player.global_position.x

	# Halfway up the screen
	var halfway_y = get_viewport_rect().size.y * 0.5

	# Make sure the stopping point is ABOVE the player
	var highest_y = halfway_y
	var lowest_y = player.global_position.y - 80

	# Safety in case the player is already above halfway
	if lowest_y < highest_y:
		lowest_y = highest_y

	var target_y = randf_range(
		highest_y,
		lowest_y
	)

	target_position = Vector2(
		target_x,
		target_y
	)

	stopping = true

	print(
		"CHAV HEADING UP! Lane: ",
		player_lane,
		" Target: ",
		target_position
	)


func update_animation(movement: Vector2):

	if movement.length() < 0.1:
		return

	if abs(movement.x) > abs(movement.y):

		if movement.x > 0:
			$AnimatedSprite2D.play("ChavRight")
		else:
			$AnimatedSprite2D.play("ChavLeft")

	else:

		if movement.y > 0:
			$AnimatedSprite2D.play("ChavDown")
		else:
			$AnimatedSprite2D.play("ChavUp")
