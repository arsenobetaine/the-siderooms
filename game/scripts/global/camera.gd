class_name Camera
extends Camera2D

@export var follow_speed: float = 5.0
@export var lookahead_distance: float = 100.0

@onready var player = get_node("/root/level-one/player")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	position = player.position

func _process(delta: float) -> void:
	var target_position: Vector2 = player.position
	var lookahead_vector: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		lookahead_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		lookahead_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		lookahead_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		lookahead_vector.y -= 1
	
	if lookahead_vector != Vector2.ZERO:
		lookahead_vector = lookahead_vector.normalized()
		target_position += lookahead_vector * lookahead_distance
	
	var lerp_factor: float = 1.0 - exp(-follow_speed * delta)
	position = position.lerp(target_position, lerp_factor)
