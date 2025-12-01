extends Node2D

var user_placed_queen = false
var solving = false

@onready var board = $Board
@onready var ui_control = $Control
@onready var result_label = $"Control/Result Label"
@onready var solve_button = $"Control/Solve Button"
@onready var reset_button = $"Control/Reset Button"
@onready var instruction_label = $"Control/Instruction Label"

func _ready():
	init_game()
	board.solution_found.connect(_on_solution_found)
	board. no_solution.connect(_on_no_solution)

func init_game():
	user_placed_queen = false
	solving = false
	result_label.hide()
	reset_button.hide()
	solve_button.show()
	instruction_label.text = "Haz clic en una casilla para colocar tu reina"
	solve_button. disabled = true

func _input(event):
	if solving:
		return
	
	# Usuario hace clic para colocar su reina inicial
	if Input.is_action_just_pressed("left_click") and not user_placed_queen:
		var pos = get_pos_under_mouse()
		
		# Verificar que está dentro del tablero
		if pos.x >= 0 and pos.x < 8 and pos. y >= 0 and pos.y < 8:
			if board.place_queen(pos):
				user_placed_queen = true
				instruction_label.text = "Reina colocada en (" + str(int(pos.x)) + ", " + str(int(pos.y)) + ")"
				solve_button.disabled = false

func get_pos_under_mouse() -> Vector2:
	var pos = get_global_mouse_position()
	pos. x = int(pos.x / 60)
	pos.y = int(pos.y / 60)
	return pos

func _on_solve_button_pressed():
	if not user_placed_queen:
		return
	
	solving = true
	instruction_label.text = "Buscando solución..."
	solve_button.hide()
	
	# Pequeña pausa para mostrar el mensaje
	await get_tree().create_timer(0.1).timeout
	
	var found = board.solve_from_user_queen()
	
	if not found:
		instruction_label.text = "Buscando en otras configuraciones..."

func _on_solution_found(positions: Array):
	solving = false
	result_label.text = "SOLUCIÓN ENCONTRADA!\nSe pueden colocar 8 reinas"
	result_label.add_theme_color_override("font_color", Color.GREEN)
	result_label.show()
	reset_button.show() 
	instruction_label.text = "Las 8 reinas están colocadas sin atacarse"

func _on_no_solution():
	solving = false
	result_label.text = "NO ES POSIBLE\nNo se pueden colocar 7 reinas más\ndesde esta posición inicial"
	result_label.add_theme_color_override("font_color", Color.RED)
	result_label.show()
	reset_button.show()
	instruction_label.text = "Intenta con otra posición inicial"

func _on_reset_button_pressed():
	board.clear_all_queens()
	init_game()
	#result_label.hide()
