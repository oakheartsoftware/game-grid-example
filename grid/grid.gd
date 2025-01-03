class_name Grid extends Node2D

@export var grid_size: int = 9
@export var spacing: int = 5

@export var chunky_leech: CompressedTexture2D
@export var pawn_leech: CompressedTexture2D

const SQUARE: PackedScene = preload("res://grid/square.tscn")

const SQUARE_SIZE: int = 64

## 2D array to store references to all of the grid spaces
var squares: Array = []

var selected_square: Square = null


func _ready() -> void:
	_init_grid()


func _init_grid() -> void:
	squares.resize(grid_size)
	
	for row in range(grid_size):
		squares[row] = []
		squares[row].resize(grid_size)
		
		for col in range(grid_size):
			var square: Square = SQUARE.instantiate()
			add_child(square)

			# Tell the square where it is
			square.set_grid_position(Vector2i(row, col))
			
			# connect the click event to know when it's clicked
			square.clicked.connect(_handle_clicked_square)
			
			# Offset the square to it's grid position
			# Row is the y dimension and column is the x dimension when drawing,
			# so it is flipped in the vector2
			square.position = Vector2(col, row) * (SQUARE_SIZE + spacing)
			
			squares[row][col] = square
	
	_add_in_leeches()


func _add_in_leeches() -> void:
	_get_square(Vector2i(4, 0)).add_leech(chunky_leech)
	
	_get_square(Vector2i(3, 1)).add_leech(pawn_leech)
	_get_square(Vector2i(5, 1)).add_leech(pawn_leech)


## Helper method to get a Square from the grid pos and cast it to the Square class
## (Becuase typed 2D arrays in GDScript don't exist...) 
func _get_square(grid_position: Vector2i) -> Square:
	var square: Square = squares[grid_position.x][grid_position.y]
	
	return square


func _handle_clicked_square(square: Square, grid_position: Vector2i) -> void:
	var square_previously_hightlighted: bool = square.highlight.visible
	
	# inefficient but simple, first ask all squares to turn off their highlighting
	for row in range(grid_size):
		for col in range(grid_size):
			_get_square(Vector2i(row, col)).set_highlight(false)
	
	if is_instance_valid(selected_square):
		if selected_square.grid_position == grid_position:
			# deselect square that's already selected
			selected_square = null
			return
		
		if square.occupied:
			# new selection is occupied but moving to occupied square not implemented
			selected_square = square
			_highlight_surrounding_squares(selected_square.grid_position)
			return
		
		if square_previously_hightlighted: 
			# square was in range (as it was hightlighted before this click)
			# move leech to new square
			square.add_leech(selected_square.get_leech())
			selected_square.clear_leech()
			selected_square = null
			return
		
		# clicked square not occupied but also not in range, keep original selection hightlights
		_highlight_surrounding_squares(selected_square.grid_position)
		return
	
	# No currently selected square, select clicked one if it's occupied
	if square.occupied:
		# Highlight all squares around the clicked one
		selected_square = square
		_highlight_surrounding_squares(grid_position)


func _highlight_surrounding_squares(grid_position: Vector2i) -> void:
	# try to look at the "row above" and "row below" but prevent going out of bounds 
	var lowest_row: int = maxi(grid_position.x - 1, 0)
	var highest_row: int = mini(grid_position.x + 1, grid_size - 1)
	
	# do the same for the columns
	var lowest_col: int = maxi(grid_position.y - 1, 0)
	var highest_col: int = mini(grid_position.y + 1, grid_size - 1)

	# iterate over all squares in this range and highlight them.
	# The upper limit of range() is EXCLUSIVE, so we have to add 1
	for row in range(lowest_row, highest_row + 1):
		for col in range(lowest_col, highest_col + 1):
			_get_square(Vector2i(row, col)).set_highlight(true)
	
	# Now hightlight 2 away in cardinal directions if possible
	# 2 above
	_highlight_square_if_possible(grid_position.x - 2, grid_position.y)
	# 2 below
	_highlight_square_if_possible(grid_position.x + 2, grid_position.y)
	# 2 left
	_highlight_square_if_possible(grid_position.x, grid_position.y - 2)
	# 2 right
	_highlight_square_if_possible(grid_position.x, grid_position.y + 2)


func _highlight_square_if_possible(row: int, col: int) -> void:
	if row < 0 or row >= grid_size:
		# row out of bounds
		return
	
	if col < 0 or col >= grid_size:
		# col out of bounds
		return

	_get_square(Vector2i(row, col)).set_highlight(true)
