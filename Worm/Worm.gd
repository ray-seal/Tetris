extends Node2D

@export var move_distance := 32.0
@export var move_interval := 0.2

@onready var head: Sprite2D = $Head
@onready var mid: Sprite2D = $Mid
@onready var ass: Sprite2D = $Ass

var direction := Vector2.RIGHT
var next_direction := Vector2.RIGHT

var touch_start := Vector2.ZERO
var swiping := false
var move_timer := 0.0

# Every body section except the head.
var body_segments = []

# Number of food items eaten.
var eaten_count := 0


func _ready():
	position = Vector2(400, 300)

	body_segments = [mid, ass]

	head.position = snap_to_grid(head.position)
	mid.position = snap_to_grid(mid.position)
	ass.position = snap_to_grid(ass.position)


func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		round(pos.x / move_distance) * move_distance,
		round(pos.y / move_distance) * move_distance
	)


func _process(delta):
	handle_keyboard()

	move_timer += delta

	if move_timer >= move_interval:
		move_timer = 0.0
		move_worm()


func handle_keyboard():
	if Input.is_action_just_pressed("ui_up"):
		change_direction(Vector2.UP)

	elif Input.is_action_just_pressed("ui_down"):
		change_direction(Vector2.DOWN)

	elif Input.is_action_just_pressed("ui_left"):
		change_direction(Vector2.LEFT)

	elif Input.is_action_just_pressed("ui_right"):
		change_direction(Vector2.RIGHT)

	elif Input.is_key_pressed(KEY_W):
		change_direction(Vector2.UP)

	elif Input.is_key_pressed(KEY_S):
		change_direction(Vector2.DOWN)

	elif Input.is_key_pressed(KEY_A):
		change_direction(Vector2.LEFT)

	elif Input.is_key_pressed(KEY_D):
		change_direction(Vector2.RIGHT)


func change_direction(new_direction: Vector2):
	# Don't allow the worm to instantly reverse into itself.
	if new_direction == -direction:
		return

	next_direction = new_direction


func _input(event):
	if event is InputEventScreenTouch:

		if event.pressed:
			touch_start = event.position
			swiping = true

		elif swiping:
			var swipe = event.position - touch_start
			swiping = false

			if swipe.length() < 30:
				return

			if abs(swipe.x) > abs(swipe.y):
				if swipe.x > 0:
					change_direction(Vector2.RIGHT)
				else:
					change_direction(Vector2.LEFT)
			else:
				if swipe.y > 0:
					change_direction(Vector2.DOWN)
				else:
					change_direction(Vector2.UP)


func move_worm():
	direction = next_direction

	var new_head_position = head.position + direction * move_distance

	if not can_move_to(new_head_position):
		die()
		return
	
	# Remember every segment's position and rotation BEFORE moving.
	var old_positions = []
	var old_rotations = []

	for segment in body_segments:
		old_positions.append(segment.position)
		old_rotations.append(segment.rotation)

	var old_head_position = head.position
	var old_head_rotation = head.rotation

	head.position = new_head_position
	head.rotation = direction.angle()

	for i in range(body_segments.size()):
		var segment = body_segments[i]

		if i == 0:
			segment.position = old_head_position
			segment.rotation = old_head_rotation
		else:
			segment.position = old_positions[i - 1]
			segment.rotation = old_rotations[i - 1]
	# Move the head.
	head.position += direction * move_distance
	head.rotation = direction.angle()

	# Every segment follows the position and rotation of the
	# segment that was in front of it.
	for i in range(body_segments.size()):
		var segment = body_segments[i]

		if i == 0:
			segment.position = old_head_position
			segment.rotation = old_head_rotation
		else:
			segment.position = old_positions[i - 1]
			segment.rotation = old_rotations[i - 1]


func grow_worm():
	# Create one new middle section at the tail.
	var new_mid = mid.duplicate()

	# Put it where the current tail is.
	new_mid.position = ass.position
	new_mid.rotation = ass.rotation

	add_child(new_mid)

	# Insert it immediately before the tail.
	body_segments.insert(body_segments.size() - 1, new_mid)

	# Increase the score.
	eaten_count += 1

	print("Eaten: ", eaten_count)


func die():
	get_tree().paused = true

	var death_screen = CanvasLayer.new()
	death_screen.layer = 100
	death_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(death_screen)

	var black = ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black.process_mode = Node.PROCESS_MODE_ALWAYS
	death_screen.add_child(black)

	var font = load("res://PressStart2P-Regular.ttf")

	# Main centred layout
	var layout = VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.position = Vector2(-300, -150)
	layout.size = Vector2(600, 300)
	layout.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_theme_constant_override("separation", 20)
	layout.process_mode = Node.PROCESS_MODE_ALWAYS
	black.add_child(layout)

	# Death message
	var message = Label.new()
	message.text = "Man walks into a bar, ouch!"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.custom_minimum_size = Vector2(600, 80)
	message.add_theme_font_override("font", font)
	message.add_theme_font_size_override("font_size", 24)
	message.add_theme_color_override("font_color", Color("#7CFF00"))
	message.process_mode = Node.PROCESS_MODE_ALWAYS
	layout.add_child(message)

	# Play Again button
	var button = Button.new()
	button.text = "PLAY AGAIN"
	button.custom_minimum_size = Vector2(200, 60)
	button.add_theme_font_size_override("font_size", 20)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	layout.add_child(button)

	button.pressed.connect(restart_game)

	# Back to Arcade button
	var arcade_button = Button.new()
	arcade_button.text = "BACK TO ARCADE"
	arcade_button.custom_minimum_size = Vector2(200, 60)
	arcade_button.add_theme_font_size_override("font_size", 20)
	arcade_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	arcade_button.process_mode = Node.PROCESS_MODE_ALWAYS
	arcade_button.mouse_filter = Control.MOUSE_FILTER_STOP
	layout.add_child(arcade_button)

	arcade_button.pressed.connect(back_to_arcade)

	# Score underneath the buttons
	var score_label = Label.new()
	score_label.text = "SCORE: " + str(eaten_count)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.custom_minimum_size = Vector2(600, 50)
	score_label.add_theme_font_override("font", font)
	score_label.add_theme_font_size_override("font_size", 20)
	score_label.add_theme_color_override("font_color", Color("#7CFF00"))
	score_label.process_mode = Node.PROCESS_MODE_ALWAYS
	layout.add_child(score_label)


func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()


func back_to_arcade():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Arcade.tscn")

func _on_head_area_body_entered(body: Node2D):
	die()
	
func can_move_to(new_position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsPointQueryParameters2D.new()
	query.position = to_global(new_position)
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var results = space_state.intersect_point(query)

	for result in results:
		var collider = result["collider"]

		# Ignore the worm itself.
		if collider is Node and collider.is_inside_tree():
			if collider.get_parent() == self:
				continue

			# Any StaticBody2D here is one of the sewer walls.
			if collider is StaticBody2D:
				return false

	return true
