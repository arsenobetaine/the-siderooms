class_name Camera
extends Camera2D

@export var follow_speed: float = 5.0
@export var lookahead_distance: float = 100.0

@onready var player = get_node("/root/level-one/player")
@onready var ui: CanvasLayer = $ui
@onready var w_key: TouchScreenButton = $"ui/w-key"
@onready var a_key: TouchScreenButton = $"ui/a-key"
@onready var s_key: TouchScreenButton = $"ui/s-key"
@onready var d_key: TouchScreenButton = $"ui/d-key"
@onready var up_key: TouchScreenButton = $"ui/up-key"
@onready var down_key: TouchScreenButton = $"ui/down-key"
@onready var left_key: TouchScreenButton = $"ui/left-key"
@onready var right_key: TouchScreenButton = $"ui/right-key"
@onready var f11_key: TouchScreenButton = $"ui/f11-key"
@onready var esc_key: TouchScreenButton = $"ui/esc-key"
@onready var shift_key: TouchScreenButton = $"ui/shift-key"
@onready var q_key: TouchScreenButton = $"ui/q-key"
@onready var e_key: TouchScreenButton = $"ui/e-key"

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
@onready var q_key_base_scale: Vector2 = q_key.scale
@onready var e_key_base_scale: Vector2 = e_key.scale

# Variables to track touch states (shared with player.gd and keybindings.gd)
var w_pressed: bool = false
var a_pressed: bool = false
var s_pressed: bool = false
var d_pressed: bool = false
var up_pressed: bool = false
var down_pressed: bool = false
var left_pressed: bool = false
var right_pressed: bool = false
var f11_pressed: bool = false
var esc_pressed: bool = false
var shift_pressed: bool = false
var q_pressed: bool = false
var e_pressed: bool = false

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
	q_key.visible = true
	e_key.visible = true

	# Connect touch signals
	w_key.pressed.connect(func(): w_pressed = true)
	w_key.released.connect(func(): w_pressed = false)
	a_key.pressed.connect(func(): a_pressed = true)
	a_key.released.connect(func(): a_pressed = false)
	s_key.pressed.connect(func(): s_pressed = true)
	s_key.released.connect(func(): s_pressed = false)
	d_key.pressed.connect(func(): d_pressed = true)
	d_key.released.connect(func(): d_pressed = false)
	up_key.pressed.connect(func(): up_pressed = true)
	up_key.released.connect(func(): up_pressed = false)
	down_key.pressed.connect(func(): down_pressed = true)
	down_key.released.connect(func(): down_pressed = false)  # Fixed typo here
	left_key.pressed.connect(func(): left_pressed = true)
	left_key.released.connect(func(): left_pressed = false)
	right_key.pressed.connect(func(): right_pressed = true)
	right_key.released.connect(func(): right_pressed = false)
	f11_key.pressed.connect(func(): f11_pressed = true)
	f11_key.released.connect(func(): f11_pressed = false)
	esc_key.pressed.connect(func(): esc_pressed = true)
	esc_key.released.connect(func(): esc_pressed = false)
	shift_key.pressed.connect(func(): shift_pressed = true)
	shift_key.released.connect(func(): shift_pressed = false)
	q_key.pressed.connect(func(): q_pressed = true)
	q_key.released.connect(func(): q_pressed = false)
	e_key.pressed.connect(func(): e_pressed = true)
	e_key.released.connect(func(): e_pressed = false)

func _process(delta):
	var target_position = player.position
	var lookahead_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right") or right_pressed:
		lookahead_vector.x += 1
		right_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		right_key.modulate = Color(1, 1, 1, 1)
	if Input.is_action_pressed("ui_left") or left_pressed:
		lookahead_vector.x -= 1
		left_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		left_key.modulate = Color(1, 1, 1, 1)
	if Input.is_action_pressed("ui_down") or down_pressed:
		lookahead_vector.y += 1
		down_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		down_key.modulate = Color(1, 1, 1, 1)
	if Input.is_action_pressed("ui_up") or up_pressed:
		lookahead_vector.y -= 1
		up_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		up_key.modulate = Color(1, 1, 1, 1)
	
	if Input.is_key_pressed(KEY_W) or w_pressed:
		w_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		w_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_A) or a_pressed:
		a_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		a_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_S) or s_pressed:
		s_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		s_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_D) or d_pressed:
		d_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		d_key.modulate = Color(1, 1, 1, 1)
	
	if Input.is_key_pressed(KEY_F11) or f11_pressed:
		f11_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		f11_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_ESCAPE) or esc_pressed:
		esc_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		esc_key.modulate = Color(1, 1, 1, 1)
	
	if Input.is_key_pressed(KEY_SHIFT) or shift_pressed:
		shift_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		shift_key.modulate = Color(1, 1, 1, 1)
	
	if Input.is_key_pressed(KEY_Q) or q_pressed:
		q_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		q_key.modulate = Color(1, 1, 1, 1)
	if Input.is_key_pressed(KEY_E) or e_pressed:
		e_key.modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		e_key.modulate = Color(1, 1, 1, 1)
	
	if lookahead_vector != Vector2.ZERO:
		lookahead_vector = lookahead_vector.normalized()
		target_position += lookahead_vector * lookahead_distance
	
	var lerp_factor = 1.0 - exp(-follow_speed * delta)
	position = position.lerp(target_position, lerp_factor)
	if ui != null:
		ui.offset = position
