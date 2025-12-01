extends Node2D

@export var pieces = []; #contiene todas laspiezas del tablero b&w
@export var piece_scene = preload("res://scenes/Piece.tscn") #escena precargada se utiliza como molde

#para verificr jaque
@export var white_king_pos: Vector2 #posicion del rey blanco en el tab
@export var black_king_pos: Vector2 #pos del rey negro

const CELL_SIZE = 60 #tam de cada casilla del tablero en pixeles

#primero dibuja el tablero luego coloca las piezas 
func _ready():
	draw_board()
	init_pieces()

#dibuja todas las casillas del tablero (8x8=64)
func draw_board():
	for x in range(8):
		for y in range(8):
			draw_cell(x, y)

#dibuja una casilla individual en la pos (x,y)
#alternan colores como tablero real xd
func draw_cell(x, y):
	var rect = ColorRect.new()
	# si la suma de x y y es par , color claro; impar: oscuro
	rect.color = Color(0.8, 0.6, 0.4) if (x + y) % 2 == 0 else Color(0.4, 0.3, 0.2)
	rect.size = Vector2(CELL_SIZE, CELL_SIZE)
	rect.position = Vector2(
		x * CELL_SIZE,
		y * CELL_SIZE
	)
	rect.z_index = -100
	add_child(rect)

#inicialixa todas las piezas del juego
func init_pieces():
	#recorre la lista de piezas iniciales definidas en globals
	for piece_tuple in Globals.INITIAL_PIECE_SET_SINGLE:
		var piece_type = piece_tuple[0] 
		#pos de la pieza negra (superior)
		var black_piece_pos = Vector2(piece_tuple[1], piece_tuple[2])
		#pos de la pieza blanca espejeada (8-1 para inveritir posiciones)
		var white_piece_pos = Vector2(piece_tuple[1], 8 -  1 - piece_tuple[2])
		
		var black_piece = piece_scene.instantiate()
		add_child(black_piece)
		black_piece.init_piece(
			piece_type,
			Globals.COLORS.BLACK,
			black_piece_pos,
			self
		)
		pieces.append(black_piece)
		
		# crea pieza blnca
		var white_piece = piece_scene.instantiate()
		add_child(white_piece)
		white_piece.init_piece(
			piece_type,
			Globals.COLORS.WHITE,
			white_piece_pos,
			self
		)
		pieces.append(white_piece)
		#si hay un rey guardar su posicion especial
		if piece_type == Globals.PIECE_TYPES.KING:
			register_king(white_piece_pos, Globals.COLORS.WHITE)
			register_king(black_piece_pos, Globals.COLORS.BLACK)

#se llama cada que el rey se mueve
func register_king(pos, col):
	match col:
		Globals.COLORS.WHITE:
			white_king_pos = pos
		Globals.COLORS.BLACK:
			black_king_pos = pos


#busca y retorna la pieza que esta en una pos especif
func get_piece(pos: Vector2):
	for piece in pieces:
		if piece.board_position == pos:
			return piece

#elimina una pieza del tab
func delete_piece(piece):
	for i in range(len(pieces)):
		if pieces[i] == piece:
			var popped = pieces.pop_at(i)
			# Solo liberar si está en el árbol de escena
			if popped.is_inside_tree():
				popped.queue_free()
			return

#retorna: Lista de posiciones a donde puede moverse
func beam_search_threat(own_color, cur_x, cur_y, inc_x, inc_y):
	
	var threat_pos = [] #lista de posiciones validas
	
	#avanzar un paso en la dir indicada
	cur_x += inc_x
	cur_y += inc_y
	
	#seguir avanzzando mientras estamos dentro del tablero
	while cur_x >= 0 and cur_x < 8 and cur_y >= 0 and cur_y < 8:
		var cur_pos = Vector2(cur_x, cur_y)
		var cur_piece = get_piece(cur_pos)
		if cur_piece != null:
			#hay una pieza aqui
			if cur_piece.color != own_color:
				#es enemiga: podemos capturarla ; añadir a la lista
				threat_pos.append(cur_pos)
			break
		threat_pos.append(cur_pos)
		cur_x += inc_x
		cur_y += inc_y
	
	return threat_pos

#busca amenaza en una casilla 
func spot_search_threat(
	own_color, 
	cur_x, cur_y, 
	inc_x, inc_y,
	threat_only = false, free_only = false
):
	#calcular la pos del objetivo
	cur_x += inc_x
	cur_y += inc_y
	
	#verif dentro del tablero
	if cur_x >= 8 or cur_x < 0 or cur_y >= 8 or cur_y < 0:
		return
	
	var cur_pos = Vector2(cur_x, cur_y)
	var cur_piece = get_piece(cur_pos)
	
	if cur_piece != null:
		#hay una pieza
		if free_only:
			return
		return cur_pos if cur_piece.color != own_color else null
	return cur_pos if not threat_only else null

#crea una copia del tablero pa siular movimientos 
#la ia usa esto para pensar sin afecta el juego real
func clone():
	# Crear un nuevo nodo Board
	var new_board = Node2D.new()
	new_board.set_script(self.get_script())
	
	# Copiar las posiciones de los reyes
	new_board.white_king_pos = white_king_pos
	new_board.black_king_pos = black_king_pos
	
	# Copiar cada pieza
	new_board.pieces = []
	for piece in pieces:
		var new_piece = piece.clone(new_board)
		new_board.pieces.append(new_piece)
	
	return new_board
