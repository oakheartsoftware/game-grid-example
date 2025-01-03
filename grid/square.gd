class_name Square extends Node2D

signal clicked(square: Square, grid_pos: Vector2i)

@onready var clickable_area: Area2D = %ClickableArea
@onready var highlight: Sprite2D = $Highlight
@onready var piece_sprite: Sprite2D = %PieceSprite

# Reference to where it is, so that it can tell the grid when it's clicked
var grid_position: Vector2i = Vector2i.ZERO

var occupied: bool = false


func _ready() -> void:
	# Connect the clickable areas event to this class for managing it here instead of in
	# the Area2D
	clickable_area.input_event.connect(_handle_input_event)


func set_grid_position(grid_pos: Vector2) -> void:
	grid_position = grid_pos


func set_highlight(highlight_visible: bool) -> void:
	highlight.visible = highlight_visible


func add_leech(leech_texture: CompressedTexture2D) -> void:
	piece_sprite.texture = leech_texture
	piece_sprite.visible = true
	occupied = true


func get_leech() -> Texture2D:
	return piece_sprite.texture


func clear_leech() -> void:
	piece_sprite.texture = null
	piece_sprite.visible = false
	occupied = false


## We don't need the viewport or shape index for anything
func _handle_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event is InputEventMouseButton:
		# Event is not related to the mouse, ignore it
		return 
	
	# Safely casting the event so that we can see the methods and properties in the editor
	var mouse_button_event: InputEventMouseButton = event as InputEventMouseButton
	
	if mouse_button_event.button_index == MOUSE_BUTTON_LEFT and mouse_button_event.pressed:
		# Tell anyone listening that we were clicked
		clicked.emit(self, grid_position)
