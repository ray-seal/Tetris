extends Control


# ============================================================
# GAME SETTINGS
# ============================================================

const COLS = 10
const ROWS = 20
var CELL_SIZE = 32.0


# ============================================================
# GAME DATA
# ============================================================

var board = []

var current_piece = []
var current_piece_index = 0

var next_piece_index = -1

var current_x = 0
var current_y = 0

var fall_timer = 0.0
var fall_speed = 0.5

var score = 0
var lines = 0
var level = 1
var game_over = false


# ============================================================
# TOUCH CONTROLS
# ============================================================

var touch_start_position = Vector2.ZERO
var touch_is_dragging = false


# ============================================================
# HUD
# ============================================================

@onready var score_label = $HUD/ScoreLabel
@onready var level_label = $HUD/LevelLabel
@onready var lines_label = $HUD/LinesLabel


# ============================================================
# PIXEL ARCADE FONT
# ============================================================

var pixel_font = preload("res://PressStart2P-Regular.ttf")


# ============================================================
# TETRIS PIECES
# ============================================================

var pieces = [

	# I
	[
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(2, 1),
		Vector2i(3, 1)
	],

	# O
	[
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(1, 1),
		Vector2i(2, 1)
	],

	# T
	[
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(2, 1)
	],

	# L
	[
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(2, 1)
	],

	# J
	[
		Vector2i(2, 0),
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(2, 1)
	],

	# S
	[
		Vector2i(1, 0),
		Vector2i(2, 0),
		Vector2i(0, 1),
		Vector2i(1, 1)
	],

	# Z
	[
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(1, 1),
		Vector2i(2, 1)
	]
]


# ============================================================
# PIECE COLOURS
# ============================================================

var piece_colors = [

	Color("#00FFFF"), # I - Cyan
	Color("#FFFF00"), # O - Yellow
	Color("#AA00FF"), # T - Purple
	Color("#FF8800"), # L - Orange
	Color("#4444FF"), # J - Blue
	Color("#00DD55"), # S - Green
	Color("#FF3333")  # Z - Red
]


# ============================================================
# START GAME
# ============================================================

func _ready():

	randomize()
	
	resize_game()
	get_viewport().size_changed.connect(resize_game)

	# --------------------------------------------------------
	# Pixel font for HUD labels
	# --------------------------------------------------------

	score_label.add_theme_font_override("font", pixel_font)
	level_label.add_theme_font_override("font", pixel_font)
	lines_label.add_theme_font_override("font", pixel_font)

	score_label.add_theme_font_size_override("font_size", 14)
	level_label.add_theme_font_size_override("font_size", 14)
	lines_label.add_theme_font_size_override("font_size", 14)

	# --------------------------------------------------------
	# Position status labels inside STATUS panel
	# --------------------------------------------------------

	score_label.position = Vector2(45, 280)
	level_label.position = Vector2(45, 320)
	lines_label.position = Vector2(45, 360)

	# --------------------------------------------------------
	# Create empty board
	# --------------------------------------------------------

	for y in range(ROWS):

		var row = []

		for x in range(COLS):

			row.append(-1)

		board.append(row)

	spawn_piece()
	update_hud()

	queue_redraw()

# ============================================================
# RESPONSIVE GAME SIZE
# ============================================================

func resize_game():

	var viewport_size = get_viewport_rect().size

	# Space available for the 10 x 20 board
	var available_width = viewport_size.x * 0.42
	var available_height = viewport_size.y * 0.62

	# Calculate a cell size that keeps the board proportional
	var width_cell_size = available_width / COLS
	var height_cell_size = available_height / ROWS

	CELL_SIZE = min(
		width_cell_size,
		height_cell_size
	)

	# Keep the game from becoming ridiculously tiny
	CELL_SIZE = max(CELL_SIZE, 20.0)

# ============================================================
# GAME LOOP
# ============================================================

func _process(delta):

	if game_over:
		return

	fall_timer += delta

	if fall_timer >= fall_speed:

		fall_timer = 0.0

		move_down()

	queue_redraw()


# ============================================================
# INPUT
# ============================================================

func _input(event):

	# --------------------------------------------------------
	# GAME OVER INPUT
	# --------------------------------------------------------

	if game_over:

		if event is InputEventKey and event.pressed:

			if event.keycode == KEY_R:

				get_tree().reload_current_scene()

			elif event.keycode == KEY_ESCAPE:

				get_tree().change_scene_to_file("res://Arcade.tscn")


		elif event is InputEventMouseButton:

			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:

				handle_game_over_click(event.position)


		elif event is InputEventScreenTouch:

			if not event.pressed:

				handle_game_over_click(event.position)

		return
	# --------------------------------------------------------
	# KEYBOARD
	# --------------------------------------------------------

	if event is InputEventKey and event.pressed:

		if event.keycode == KEY_LEFT:

			move_horizontal(-1)

		elif event.keycode == KEY_RIGHT:

			move_horizontal(1)

		elif event.keycode == KEY_DOWN:

			move_down()

		elif event.keycode == KEY_UP:

			rotate_piece()

		elif event.keycode == KEY_SPACE:

			hard_drop()


	# --------------------------------------------------------
	# TOUCH
	# --------------------------------------------------------

	elif event is InputEventScreenTouch:

		if event.pressed:

			touch_start_position = event.position
			touch_is_dragging = false

		else:

			# A tap without a swipe rotates the piece.

			if not touch_is_dragging:

				rotate_piece()


	# --------------------------------------------------------
	# TOUCH DRAG
	# --------------------------------------------------------

	elif event is InputEventScreenDrag:

		# ----------------------------------------------------
		# IMPORTANT:
		# Once this touch has performed an action,
		# ignore the rest of the drag.
		# This prevents one swipe from dropping
		# multiple pieces.
		# ----------------------------------------------------

		if touch_is_dragging:

			return


		var horizontal_distance = (
			event.position.x - touch_start_position.x
		)

		var vertical_distance = (
			event.position.y - touch_start_position.y
		)


		# ----------------------------------------------------
		# DOWNWARD SWIPE = HARD DROP
		# ----------------------------------------------------

		if vertical_distance >= CELL_SIZE * 1.5:

			hard_drop()

			touch_is_dragging = true

			return


		# ----------------------------------------------------
		# HORIZONTAL SWIPE = MOVE
		# ----------------------------------------------------

		if abs(horizontal_distance) >= CELL_SIZE * 0.6:

			if horizontal_distance > 0:

				move_horizontal(1)

			else:

				move_horizontal(-1)

			touch_start_position = event.position
			touch_is_dragging = true


# ============================================================
# SPAWN PIECE
# ============================================================

func spawn_piece():

	if next_piece_index == -1:

		current_piece_index = randi() % pieces.size()

	else:

		current_piece_index = next_piece_index

	next_piece_index = randi() % pieces.size()

	current_piece = pieces[current_piece_index].duplicate()

	current_x = 3
	current_y = 0

	if not can_move(
		current_piece,
		current_x,
		current_y
	):

		game_over = true


# ============================================================
# MOVE LEFT / RIGHT
# ============================================================

func move_horizontal(direction):

	var new_x = current_x + direction

	if can_move(
		current_piece,
		new_x,
		current_y
	):

		current_x = new_x


# ============================================================
# MOVE DOWN
# ============================================================

func move_down():

	var new_y = current_y + 1

	if can_move(
		current_piece,
		current_x,
		new_y
	):

		current_y = new_y

	else:

		lock_piece()


# ============================================================
# HARD DROP
# ============================================================

func hard_drop():

	while can_move(
		current_piece,
		current_x,
		current_y + 1
	):

		current_y += 1

	lock_piece()


# ============================================================
# ROTATE
# ============================================================

func rotate_piece():

	var rotated_piece = []

	for block in current_piece:

		var new_x = -block.y
		var new_y = block.x

		rotated_piece.append(
			Vector2i(new_x, new_y)
		)

	var min_x = 999
	var min_y = 999

	for block in rotated_piece:

		min_x = min(min_x, block.x)
		min_y = min(min_y, block.y)

	for i in range(rotated_piece.size()):

		rotated_piece[i].x -= min_x
		rotated_piece[i].y -= min_y

	if can_move(
		rotated_piece,
		current_x,
		current_y
	):

		current_piece = rotated_piece


# ============================================================
# CHECK WHETHER PIECE CAN MOVE
# ============================================================

func can_move(piece, test_x, test_y):

	for block in piece:

		var x = test_x + block.x
		var y = test_y + block.y

		if x < 0 or x >= COLS:

			return false

		if y < 0 or y >= ROWS:

			return false

		if board[y][x] != -1:

			return false

	return true


# ============================================================
# LOCK PIECE INTO BOARD
# ============================================================

func lock_piece():

	for block in current_piece:

		var x = current_x + block.x
		var y = current_y + block.y

		if y >= 0 and y < ROWS:

			board[y][x] = current_piece_index

	clear_lines()

	spawn_piece()


# ============================================================
# CLEAR COMPLETED LINES
# ============================================================

func clear_lines():

	var lines_cleared = 0
	var y = ROWS - 1

	while y >= 0:

		var full = true

		for x in range(COLS):

			if board[y][x] == -1:

				full = false
				break

		if full:

			board.remove_at(y)

			var empty_row = []

			for x in range(COLS):

				empty_row.append(-1)

			board.push_front(empty_row)

			lines_cleared += 1

		else:

			y -= 1


	# --------------------------------------------------------
	# Lines were cleared
	# --------------------------------------------------------

	if lines_cleared > 0:

		lines += lines_cleared

		# 1 line  = 1 point
		# 2 lines = 3 points
		# 3 lines = 5 points
		# 4 lines = 7 points

		score += lines_cleared + (lines_cleared - 1)

		# Level increases every 10 lines

		level = floori(lines / 10.0) + 1

		# Game gets faster each level

		fall_speed = max(
			0.10,
			0.5 - ((level - 1) * 0.04)
		)

		update_hud()


# ============================================================
# UPDATE HUD
# ============================================================

func update_hud():

	score_label.text = "SCORE: " + str(score)

	level_label.text = "LEVEL: " + str(level)

	lines_label.text = "LINES: " + str(lines)


# ============================================================
# DRAW EVERYTHING
# ============================================================

func _draw():

	# --------------------------------------------------------
	# BACKGROUND
	# --------------------------------------------------------

	draw_rect(
		Rect2(
			0,
			0,
			size.x,
			size.y
		),
		Color("#111111")
	)


	# --------------------------------------------------------
	# ARCADE BORDER
	# --------------------------------------------------------

	draw_rect(
		Rect2(
			8,
			8,
			size.x - 16,
			size.y - 16
		),
		Color("#333333"),
		false,
		4.0
	)

	draw_rect(
		Rect2(
			14,
			14,
			size.x - 28,
			size.y - 28
		),
		Color("#666666"),
		false,
		1.0
	)


	# --------------------------------------------------------
	# BOARD SIZE
	# --------------------------------------------------------

	var board_width = COLS * CELL_SIZE
	var board_height = ROWS * CELL_SIZE

	var start_x = (size.x - board_width) / 2
	var start_y = (size.y - board_height) / 2


	# --------------------------------------------------------
	# FONT
	# --------------------------------------------------------

	var panel_font = pixel_font


	# --------------------------------------------------------
	# STATUS PANEL
	# --------------------------------------------------------

	var status_panel_x = 25
	var status_panel_y = 235

	var status_panel_width = max(
		150.0,
		start_x - 50.0
	)

	var status_panel_height = 165.0


	# Panel background

	draw_rect(
		Rect2(
			status_panel_x,
			status_panel_y,
			status_panel_width,
			status_panel_height
		),
		Color("#222222")
	)


	# Cyan arcade border

	draw_rect(
		Rect2(
			status_panel_x,
			status_panel_y,
			status_panel_width,
			status_panel_height
		),
		Color("#00FFFF"),
		false,
		3.0
	)


	# STATUS heading

	draw_string(
		panel_font,
		Vector2(
			status_panel_x + 20,
			status_panel_y + 30
		),
		"STATUS",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		22,
		Color("#00FFFF")
	)


	# --------------------------------------------------------
	# NEXT PIECE PANEL
	# --------------------------------------------------------

	var next_panel_x = (
		start_x + board_width + 25
	)

	var next_panel_y = 115

	var next_panel_width = min(
		180.0,
		size.x - next_panel_x - 25.0
	)

	var next_panel_height = 190.0


	# Panel background

	draw_rect(
		Rect2(
			next_panel_x,
			next_panel_y,
			next_panel_width,
			next_panel_height
		),
		Color("#222222")
	)


	# Cyan arcade border

	draw_rect(
		Rect2(
			next_panel_x,
			next_panel_y,
			next_panel_width,
			next_panel_height
		),
		Color("#00FFFF"),
		false,
		3.0
	)


	# --------------------------------------------------------
	# BOARD BACKGROUND
	# --------------------------------------------------------

	draw_rect(
		Rect2(
			start_x,
			start_y,
			board_width,
			board_height
		),
		Color("#181818")
	)


	# --------------------------------------------------------
	# VERTICAL GRID
	# --------------------------------------------------------

	for x in range(COLS + 1):

		var line_x = start_x + x * CELL_SIZE

		draw_line(
			Vector2(
				line_x,
				start_y
			),
			Vector2(
				line_x,
				start_y + board_height
			),
			Color("#333333"),
			1.0
		)


	# --------------------------------------------------------
	# HORIZONTAL GRID
	# --------------------------------------------------------

	for y in range(ROWS + 1):

		var line_y = start_y + y * CELL_SIZE

		draw_line(
			Vector2(
				start_x,
				line_y
			),
			Vector2(
				start_x + board_width,
				line_y
			),
			Color("#333333"),
			1.0
		)


	# --------------------------------------------------------
	# LOCKED BLOCKS
	# --------------------------------------------------------

	for y in range(ROWS):

		for x in range(COLS):

			if board[y][x] != -1:

				draw_block(
					start_x + x * CELL_SIZE,
					start_y + y * CELL_SIZE,
					piece_colors[board[y][x]]
				)


	# --------------------------------------------------------
	# CURRENT FALLING PIECE
	# --------------------------------------------------------

	if not game_over:

		for block in current_piece:

			var x = current_x + block.x
			var y = current_y + block.y

			draw_block(
				start_x + x * CELL_SIZE,
				start_y + y * CELL_SIZE,
				piece_colors[current_piece_index]
			)


	# --------------------------------------------------------
	# NEXT PIECE
	# --------------------------------------------------------

	if next_piece_index >= 0:

		var preview_x = next_panel_x + 35
		var preview_y = next_panel_y + 65


		# NEXT text

		draw_string(
			panel_font,
			Vector2(
				next_panel_x + 20,
				next_panel_y + 38
			),
			"NEXT",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			24,
			Color("#FFFFFF")
		)


		# Preview blocks

		for block in pieces[next_piece_index]:

			var preview_block_x = (
				preview_x + block.x * 20
			)

			var preview_block_y = (
				preview_y + block.y * 20
			)

			draw_rect(
				Rect2(
					preview_block_x + 1,
					preview_block_y + 1,
					18,
					18
				),
				piece_colors[next_piece_index]
			)

	# --------------------------------------------------------
	# GAME OVER SCREEN
	# --------------------------------------------------------

	if game_over:

		var center_x = size.x / 2.0
		var center_y = size.y / 2.0

		var panel_width = min(500.0, size.x - 40.0)
		var panel_height = 330.0

		var panel_x = center_x - panel_width / 2.0
		var panel_y = center_y - panel_height / 2.0


		# ----------------------------------------------------
		# Dark overlay
		# ----------------------------------------------------

		draw_rect(
			Rect2(
				0,
				0,
				size.x,
				size.y
			),
			Color(0, 0, 0, 0.65)
		)


		# ----------------------------------------------------
		# Game over panel
		# ----------------------------------------------------

		draw_rect(
			Rect2(
				panel_x,
				panel_y,
				panel_width,
				panel_height
			),
			Color("#181818")
		)

		draw_rect(
			Rect2(
				panel_x,
				panel_y,
				panel_width,
				panel_height
			),
			Color("#00FFFF"),
			false,
			4.0
		)

	# --------------------------------------------------------
	# GAME OVER SCREEN
	# --------------------------------------------------------

	if game_over:

		var center_x = size.x / 2.0
		var center_y = size.y / 2.0

		var panel_width = min(500.0, size.x - 40.0)
		var panel_height = 330.0

		var panel_x = center_x - panel_width / 2.0
		var panel_y = center_y - panel_height / 2.0


		# ----------------------------------------------------
		# DARK OVERLAY
		# ----------------------------------------------------

		draw_rect(
			Rect2(
				0,
				0,
				size.x,
				size.y
			),
			Color(0, 0, 0, 0.65)
		)


		# ----------------------------------------------------
		# GAME OVER PANEL
		# ----------------------------------------------------

		draw_rect(
			Rect2(
				panel_x,
				panel_y,
				panel_width,
				panel_height
			),
			Color("#181818")
		)

		draw_rect(
			Rect2(
				panel_x,
				panel_y,
				panel_width,
				panel_height
			),
			Color("#00FFFF"),
			false,
			4.0
		)


		# ----------------------------------------------------
		# GAME OVER TITLE
		# ----------------------------------------------------

		draw_string(
			pixel_font,
			Vector2(
				panel_x,
				panel_y + 60
			),
			"GAME OVER",
			HORIZONTAL_ALIGNMENT_CENTER,
			panel_width,
			28,
			Color("#FFFFFF")
		)


		# ----------------------------------------------------
		# FINAL SCORE
		# ----------------------------------------------------

		draw_string(
			pixel_font,
			Vector2(
				panel_x,
				panel_y + 100
			),
			"FINAL SCORE: " + str(score),
			HORIZONTAL_ALIGNMENT_CENTER,
			panel_width,
			16,
			Color("#00FFFF")
		)


		# ----------------------------------------------------
		# BUTTON SETTINGS
		# ----------------------------------------------------

		var button_width = min(
			300.0,
			panel_width - 40.0
		)

		var button_height = 55.0

		var button_x = (
			center_x - button_width / 2.0
		)


		# ----------------------------------------------------
		# PLAY AGAIN BUTTON
		# ----------------------------------------------------

		var play_y = panel_y + 135

		draw_rect(
			Rect2(
				button_x,
				play_y,
				button_width,
				button_height
			),
			Color("#222222")
		)

		draw_rect(
			Rect2(
				button_x,
				play_y,
				button_width,
				button_height
			),
			Color("#00FFFF"),
			false,
			3.0
		)

		draw_string(
			pixel_font,
			Vector2(
				button_x,
				play_y + 35
			),
			"PLAY AGAIN",
			HORIZONTAL_ALIGNMENT_CENTER,
			button_width,
			18,
			Color("#FFFFFF")
		)


		# ----------------------------------------------------
		# BACK TO ARCADE BUTTON
		# ----------------------------------------------------

		var arcade_y = panel_y + 205

		draw_rect(
			Rect2(
				button_x,
				arcade_y,
				button_width,
				button_height
			),
			Color("#222222")
		)

		draw_rect(
			Rect2(
				button_x,
				arcade_y,
				button_width,
				button_height
			),
			Color("#00FFFF"),
			false,
			3.0
		)

		draw_string(
			pixel_font,
			Vector2(
				button_x,
				arcade_y + 35
			),
			"BACK TO ARCADE",
			HORIZONTAL_ALIGNMENT_CENTER,
			button_width,
			16,
			Color("#FFFFFF")
		)
		
# ============================================================
# DRAW ONE BLOCK
# ============================================================

func draw_block(x, y, block_color):

	# --------------------------------------------------------
	# Main block
	# --------------------------------------------------------

	draw_rect(
		Rect2(
			x + 2,
			y + 2,
			CELL_SIZE - 4,
			CELL_SIZE - 4
		),
		block_color
	)


	# --------------------------------------------------------
	# Bright top edge
	# --------------------------------------------------------

	draw_rect(
		Rect2(
			x + 3,
			y + 3,
			CELL_SIZE - 6,
			4
		),
		block_color.lightened(0.35)
	)


	# --------------------------------------------------------
	# Dark bottom edge
	# --------------------------------------------------------

	draw_rect(
		Rect2(
			x + 3,
			y + CELL_SIZE - 7,
			CELL_SIZE - 6,
			4
		),
		block_color.darkened(0.35)
	)

# ============================================================
# GAME OVER BUTTONS
# ============================================================

func handle_game_over_click(click_position):

	var center_x = size.x / 2.0
	var center_y = size.y / 2.0

	var panel_height = 330.0
	var panel_y = center_y - panel_height / 2.0

	var panel_width = min(500.0, size.x - 40.0)

	var button_width = min(300.0, panel_width - 40.0)
	var button_height = 55.0

	var button_x = center_x - button_width / 2.0

	var play_again_rect = Rect2(
		button_x,
		panel_y + 135,
		button_width,
		button_height
	)

	var arcade_rect = Rect2(
		button_x,
		panel_y + 205,
		button_width,
		button_height
	)

	if play_again_rect.has_point(click_position):

		get_tree().reload_current_scene()

	elif arcade_rect.has_point(click_position):

		get_tree().change_scene_to_file("res://Arcade.tscn")
