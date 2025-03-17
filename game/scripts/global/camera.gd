class_name Camera
extends Camera2D

@export var follow_speed: float = 5.0
@export var lookahead_distance: float = 100.0

@onready var player = get_node("/root/level-one/player")
@onready var ui: CanvasLayer = $ui
@onready var w_key: TextureRect = $"ui/w-key"
@onready var a_key: TextureRect = $"ui/a-key"
@onready var s_key: TextureRect = $"ui/s-key"
@onready var d_key: TextureRect = $"ui/d-key"
@onready var up_key: TextureRect = $"ui/up-key"
@onready var down_key: TextureRect = $"ui/down-key"
@onready var left_key: TextureRect = $"ui/left-key"
@onready var right_key: TextureRect = $"ui/right-key"
@onready var f11_key: TextureRect = $"ui/f11-key"
@onready var esc_key: TextureRect = $"ui/esc-key"
@onready var shift_key: TextureRect = $"ui/shift-key"

@onready var w_key_base_scale: Vector2 = w_key.scale
@onready var a_key_base_scale: Vector2 = a_key.scale
@onready var s_key_base_scale: Vector2 = s_key.scale
@onready var d_key_base_scale: Vector2 = d_key.scale
@onready var up_key_base_scale: Vector2 = up_key.scale
@onready var down_key_base_scale: Vector2 = down_key.scale
@onready var left_key_base_scale: Vector2 = left_key.scale
@onready var right_key_base_scale: Vector2 = right_key.scale
@onready var f11_key_base_scale: Vector2 = f11_key.scale
@onready var esc_key_base_scale: Vector2 = esc_key.scale
@onready var shift_key_base_scale: Vector2 = shift_key.scale

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	position = player.position
	w_key.visible = true
	a_key.visible = true
	s_key.visible = true
	d_key.visible = true
	up_key.visible = true
	down_key.visible = true
	left_key.visible = true
	right_key.visible = true
	f11_key.visible = true
	esc_key.visible = true
	shift_key.visible = true

func _process(delta):
	var target_position = player.position
	var lookahead_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		lookahead_vector.x += 1
		right_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		right_key.modulate = Color(1, 1, 1, 1)
	if Input.is_action_pressed("ui_left"):
		lookahead_vector.x -= 1
		left_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		left_key.modulate = Color(1, 1, 1, 1)
	if Input.is_action_pressed("ui_down"):
		lookahead_vector.y += 1
		down_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		down_key.modulate = Color(1, 1, 1, 1)
	if Input.is_action_pressed("ui_up"):
		lookahead_vector.y -= 1
		up_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		up_key.modulate = Color(1, 1, 1, 1)
	
	if Input.is_key_pressed(KEY_W):
		w_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		w_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_A):
		a_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		a_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_S):
		s_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		s_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_D):
		d_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		d_key.modulate = Color(1, 1, 1, 1)
	
	if Input.is_key_pressed(KEY_F11):
		f11_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		f11_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_ESCAPE):
		esc_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		esc_key.modulate = Color(1, 1, 1, 1)
	
	if Input.is_key_pressed(KEY_SHIFT):
		shift_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		shift_key.modulate = Color(1, 1, 1, 1)
	
	if lookahead_vector != Vector2.ZERO:
		lookahead_vector = lookahead_vector.normalized()
		target_position += lookahead_vector * lookahead_distance
	
	var lerp_factor = 1.0 - exp(-follow_speed * delta)
	position = position.lerp(target_position, lerp_factor)
	if ui != null:
		ui.offset = position
