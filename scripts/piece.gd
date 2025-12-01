extends Node2D

@onready var sprite = $Sprite2D

const SPRITE_SIZE = 16
const CELL_SIZE = 60

const X_OFFSET = 30
const Y_OFFSET = 30

@export var piece_type: Globals. PIECE_TYPES
@export var color: Globals.COLORS
@export var board_position: Vector2

var board_handle

func init_piece(
	type: Globals. PIECE_TYPES,
	col: Globals.COLORS,
	board_pos: Vector2,
	board
):
	piece_type = type
	color = col
	board_position = board_pos
	board_handle = board
	
	update_sprite()
	
	position = Vector2(
		X_OFFSET + board_position.x * CELL_SIZE,
		Y_OFFSET + board_position.y * CELL_SIZE,
	)

func update_sprite():
	if sprite:
		var region_pos = Globals. SPRITE_MAPPING[color][piece_type]
		sprite.region_rect = Rect2(
			region_pos.y * SPRITE_SIZE,
			region_pos.x * SPRITE_SIZE,
			SPRITE_SIZE,
			SPRITE_SIZE
		)

func move_position(to_move: Vector2):
	board_position = to_move
	if is_inside_tree():
		position = Vector2(
			X_OFFSET + board_position.x * CELL_SIZE,
			Y_OFFSET + board_position.y * CELL_SIZE,
		)

# ========== DETECCIÓN DE AMENAZAS DE LA REINA ==========

# Retorna todas las posiciones que la reina puede atacar
# Esto es útil para verificar conflictos entre reinas
func get_threatened_positions() -> Array:
	if board_handle == null:
		return []
	return queen_threat_pos()

# Movimientos de la reina: todas las direcciones (horizontal, vertical, diagonal)
const QUEEN_BEAM_INCREMENTS = [
	[1, 0],   # derecha
	[-1, 0],  # izquierda
	[0, 1],   # abajo
	[0, -1],  # arriba
	[1, 1],   # diagonal abajo-derecha
	[1, -1],  # diagonal arriba-derecha
	[-1, 1],  # diagonal abajo-izquierda
	[-1, -1]  # diagonal arriba-izquierda
]

func queen_threat_pos() -> Array:
	var positions = []
	for inc in QUEEN_BEAM_INCREMENTS:
		positions += beam_search_threat(inc[0], inc[1])
	return positions

# Busca en una dirección hasta encontrar el borde del tablero u otra pieza
func beam_search_threat(inc_x: int, inc_y: int) -> Array:
	var threat_pos = []
	
	var cur_x = int(board_position.x) + inc_x
	var cur_y = int(board_position.y) + inc_y
	
	# Avanzar mientras estemos dentro del tablero 8x8
	while cur_x >= 0 and cur_x < 8 and cur_y >= 0 and cur_y < 8:
		var cur_pos = Vector2(cur_x, cur_y)
		var cur_piece = board_handle.get_piece(cur_pos)
		
		if cur_piece != null:
			# Hay otra reina aquí - es una amenaza/conflicto
			threat_pos.append(cur_pos)
			break  # No podemos pasar a través de otra pieza
		
		threat_pos.append(cur_pos)
		cur_x += inc_x
		cur_y += inc_y
	
	return threat_pos

# ========== VERIFICACIÓN DE ATAQUES ==========

# Verifica si esta reina está atacando a otra reina en la posición dada
func is_attacking(other_pos: Vector2) -> bool:
	var dominated = get_threatened_positions()
	return other_pos in dominated

# Verifica si esta reina está en conflicto con cualquier otra reina en el tablero
func has_conflict() -> bool:
	if board_handle == null:
		return false
	
	for piece in board_handle.pieces:
		if piece == self:
			continue
		if is_attacking(piece. board_position):
			return true
	return false

# ========== UTILIDADES ==========

# Crea una copia de la pieza (para simulaciones)
func clone(_board):
	var new_piece = Node2D.new()
	new_piece.set_script(self.get_script())
	
	new_piece.piece_type = piece_type
	new_piece.color = color
	new_piece.board_position = board_position
	new_piece.board_handle = _board
	
	return new_piece

# Resalta la pieza (útil para mostrar conflictos)
func highlight(is_conflict: bool = false):
	if sprite:
		if is_conflict:
			sprite.modulate = Color.RED
		else:
			sprite. modulate = Color. GREEN

# Quita el resaltado
func clear_highlight():
	if sprite:
		sprite. modulate = Color. WHITE
