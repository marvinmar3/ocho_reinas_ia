extends Node2D

@export var pieces = []
@export var piece_scene = preload("res://scenes/Piece.tscn")

const CELL_SIZE = 60
const BOARD_SIZE = 8

signal solution_found(positions)
signal no_solution()

func _ready():
	draw_board()

func draw_board():
	for x in range(BOARD_SIZE):
		for y in range(BOARD_SIZE):
			draw_cell(x, y)

func draw_cell(x, y):
	var rect = ColorRect.new()
	rect.color = Color(0.8, 0.6, 0.4) if (x + y) % 2 == 0 else Color(0.4, 0.3, 0.2)
	rect. size = Vector2(CELL_SIZE, CELL_SIZE)
	rect.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
	rect.z_index = -100
	add_child(rect)

func place_queen(pos: Vector2) -> bool:
	if get_piece(pos) != null:
		return false
	
	var queen = piece_scene. instantiate()
	add_child(queen)
	queen.init_piece(Globals. PIECE_TYPES. QUEEN, Globals.COLORS.WHITE, pos, self)
	pieces. append(queen)
	return true

func get_piece(pos: Vector2):
	for piece in pieces:
		if piece.board_position == pos:
			return piece
	return null

func delete_piece(piece):
	for i in range(len(pieces)):
		if pieces[i] == piece:
			var popped = pieces.pop_at(i)
			if popped. is_inside_tree():
				popped.queue_free()
			return

func clear_all_queens():
	for piece in pieces. duplicate():
		if piece.is_inside_tree():
			piece.queue_free()
	pieces. clear()

# ========== LÓGICA DEL PROBLEMA DE LAS 8 REINAS ==========

func is_safe(row: int, col: int, queen_positions: Array) -> bool:
	for queen_pos in queen_positions:
		var q_row = int(queen_pos. y)
		var q_col = int(queen_pos.x)
		
		if q_row == row:
			return false
		if q_col == col:
			return false
		if abs(q_row - row) == abs(q_col - col):
			return false
	
	return true

func get_queen_positions() -> Array:
	var positions = []
	for piece in pieces:
		positions.append(piece. board_position)
	return positions

func solve_from_user_queen() -> bool:
	var initial_positions = get_queen_positions()
	
	if initial_positions.size() == 0:
		print("No hay reina inicial")
		emit_signal("no_solution")
		return false
	
	var user_queen = initial_positions[0]
	var occupied_row = int(user_queen. y)
	
	var solution = solve_backtracking(0, initial_positions. duplicate(), occupied_row)
	
	if solution. size() == BOARD_SIZE:
		for pos in solution:
			if pos != user_queen:
				place_queen(pos)
		emit_signal("solution_found", solution)
		return true
	else:
		emit_signal("no_solution")
		return false

func solve_backtracking(row: int, current_positions: Array, skip_row: int) -> Array:
	if current_positions.size() == BOARD_SIZE:
		return current_positions
	
	if row == skip_row:
		return solve_backtracking(row + 1, current_positions, skip_row)
	
	if row >= BOARD_SIZE:
		return []
	
	for col in range(BOARD_SIZE):
		if is_safe(row, col, current_positions):
			var new_positions = current_positions.duplicate()
			new_positions.append(Vector2(col, row))
			
			var result = solve_backtracking(row + 1, new_positions, skip_row)
			
			if result.size() == BOARD_SIZE:
				return result
	
	return []
