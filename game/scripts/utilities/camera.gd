class_name Camera
extends Camera2D

enum LevelType {
	LEVEL_ONE,
	LEVEL_TWO,
	LEVEL_THREE
}

@export var level_type: LevelType = LevelType.LEVEL_ONE
@export var follow_speed: float = 5.0
@export var lookahead_distance: float = 100.0
@onready var ui: CanvasLayer = $UI
@onready var w_key: TextureButton = $UI/KeyW
@onready var a_key: TextureButton = $UI/KeyA
@onready var s_key: TextureButton = $UI/KeyS
@onready var d_key: TextureButton = $UI/KeyD
@onready var up_key: TextureButton = $UI/KeyUp
@onready var down_key: TextureButton = $UI/KeyDown
@onready var left_key: TextureButton = $UI/KeyLeft
@onready var right_key: TextureButton = $UI/KeyRight
@onready var f11_key: TextureButton = $UI/KeyF11
@onready var esc_key: TextureButton = $UI/KeyEsc
@onready var shift_key: TextureButton = $UI/KeyShift
@onready var e_key: TextureButton = $UI/KeyE
@onready var q_key: TextureButton = $UI/KeyQ
@onready var v_key: TextureButton = $UI/KeyV
@onready var inventory: Control = $UI/Inventory
@onready var background: TextureRect = $UI/Inventory/Background
@onready var slot1: TextureRect = $UI/Inventory/SlotOne
@onready var slot2: TextureRect = $UI/Inventory/SlotTwo
@onready var slot3: TextureRect = $UI/Inventory/SlotThree
@onready var ruby_count_label: Label = $UI/Inventory/RubyCount

var ruby_texture: Texture2D = preload("res://assets/graphics/entities/items/ruby.png")
var just_picked_up: bool = false
var just_picked_up_timer: float = 0.0
var player: Node = null

var pressed_color: Color = Color(0.8, 0.8, 0.8, 1.0)
var normal_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var w_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/w.png")
var w_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/w_hovered.png")
var a_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/a.png")
var a_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/a_hovered.png")
var s_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/s.png")
var s_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/s_hovered.png")
var d_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/d.png")
var d_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/d_hovered.png")
var up_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/up.png")
var up_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/up_hovered.png")
var down_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/down.png")
var down_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/down_hovered.png")
var left_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/left.png")
var left_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/left_hovered.png")
var right_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/right.png")
var right_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/right_hovered.png")
var f11_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/f11.png")
var f11_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/f11_hovered.png")
var esc_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/esc.png")
var esc_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/esc_hovered.png")
var shift_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/shift.png")
var shift_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/shift_hovered.png")
var e_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/e.png")
var e_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/e_hovered.png")
var q_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/q.png")
var q_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/q_hovered.png")
var v_key_normal: Texture2D = preload("res://assets/graphics/ui/keys/v.png")
var v_key_pressed: Texture2D = preload("res://assets/graphics/ui/keys/v_hovered.png")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player = get_tree().get_first_node_in_group("player")
	if player:
		position = player.position
	inventory.visible = false
	ruby_count_label.visible = false
	update_inventory()
	get_tree().node_added.connect(_on_node_added)
	
	_setup_key_button(w_key, w_key_normal, w_key_pressed)
	_setup_key_button(a_key, a_key_normal, a_key_pressed)
	_setup_key_button(s_key, s_key_normal, s_key_pressed)
	_setup_key_button(d_key, d_key_normal, d_key_pressed)
	_setup_key_button(up_key, up_key_normal, up_key_pressed)
	_setup_key_button(down_key, down_key_normal, down_key_pressed)
	_setup_key_button(left_key, left_key_normal, left_key_pressed)
	_setup_key_button(right_key, right_key_normal, right_key_pressed)
	_setup_key_button(f11_key, f11_key_normal, f11_key_pressed)
	_setup_key_button(esc_key, esc_key_normal, esc_key_pressed)
	_setup_key_button(shift_key, shift_key_normal, shift_key_pressed)
	_setup_key_button(e_key, e_key_normal, e_key_pressed)
	_setup_key_button(q_key, q_key_normal, q_key_pressed)
	_setup_key_button(v_key, v_key_normal, v_key_pressed)

func _setup_key_button(button: TextureButton, normal: Texture2D, pressed: Texture2D) -> void:
	button.texture_normal = normal
	button.texture_pressed = pressed
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	var target_position = player.position
	var lookahead_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		lookahead_vector.x += 1
		right_key.texture_normal = right_key_pressed
		right_key.modulate = pressed_color
	else:
		right_key.texture_normal = right_key_normal
		right_key.modulate = normal_color
	if Input.is_action_pressed("ui_left"):
		lookahead_vector.x -= 1
		left_key.texture_normal = left_key_pressed
		left_key.modulate = pressed_color
	else:
		left_key.texture_normal = left_key_normal
		left_key.modulate = normal_color
	if Input.is_action_pressed("ui_down"):
		lookahead_vector.y += 1
		down_key.texture_normal = down_key_pressed
		down_key.modulate = pressed_color
	else:
		down_key.texture_normal = down_key_normal
		down_key.modulate = normal_color
	if Input.is_action_pressed("ui_up"):
		lookahead_vector.y -= 1
		up_key.texture_normal = up_key_pressed
		up_key.modulate = pressed_color
	else:
		up_key.texture_normal = up_key_normal
		up_key.modulate = normal_color
	if Input.is_key_pressed(KEY_W):
		w_key.texture_normal = w_key_pressed
		w_key.modulate = pressed_color
	else:
		w_key.texture_normal = w_key_normal
		w_key.modulate = normal_color
	if Input.is_key_pressed(KEY_A):
		a_key.texture_normal = a_key_pressed
		a_key.modulate = pressed_color
	else:
		a_key.texture_normal = a_key_normal
		a_key.modulate = normal_color
	if Input.is_key_pressed(KEY_S):
		s_key.texture_normal = s_key_pressed
		s_key.modulate = pressed_color
	else:
		s_key.texture_normal = s_key_normal
		s_key.modulate = normal_color
	if Input.is_key_pressed(KEY_D):
		d_key.texture_normal = d_key_pressed
		d_key.modulate = pressed_color
	else:
		d_key.texture_normal = d_key_normal
		d_key.modulate = normal_color
	if Input.is_key_pressed(KEY_F11):
		f11_key.texture_normal = f11_key_pressed
		f11_key.modulate = pressed_color
	else:
		f11_key.texture_normal = f11_key_normal
		f11_key.modulate = normal_color
	if Input.is_key_pressed(KEY_ESCAPE):
		esc_key.texture_normal = esc_key_pressed
		esc_key.modulate = pressed_color
	else:
		esc_key.texture_normal = esc_key_normal
		esc_key.modulate = normal_color
	if Input.is_key_pressed(KEY_SHIFT):
		shift_key.texture_normal = shift_key_pressed
		shift_key.modulate = pressed_color
	else:
		shift_key.texture_normal = shift_key_normal
		shift_key.modulate = normal_color
	if Input.is_key_pressed(KEY_E):
		e_key.texture_normal = e_key_pressed
		e_key.modulate = pressed_color
		if Input.is_action_just_pressed("E"):
			inventory.visible = !inventory.visible
	else:
		e_key.texture_normal = e_key_normal
		e_key.modulate = normal_color
	if Input.is_action_pressed("Q"):
		q_key.texture_normal = q_key_pressed
		q_key.modulate = pressed_color
	else:
		q_key.texture_normal = q_key_normal
		q_key.modulate = normal_color
	if Input.is_key_pressed(KEY_V):
		v_key.texture_normal = v_key_pressed
		v_key.modulate = pressed_color
	else:
		v_key.texture_normal = v_key_normal
		v_key.modulate = normal_color
	
	if just_picked_up:
		just_picked_up_timer -= delta
		if just_picked_up_timer <= 0:
			just_picked_up = false
			update_inventory()
	
	if inventory.visible:
		update_inventory()
	
	if lookahead_vector != Vector2.ZERO:
		lookahead_vector = lookahead_vector.normalized()
		target_position += lookahead_vector * lookahead_distance
	
	var lerp_factor = 1.0 - exp(-follow_speed * delta)
	position = position.lerp(target_position, lerp_factor)
	if ui:
		ui.offset = position

func update_inventory():
	if player and "inventory" in player and player.inventory["rubies"] > 0:
		slot1.texture = ruby_texture
		ruby_count_label.text = str(player.inventory["rubies"])
		ruby_count_label.visible = true
	else:
		slot1.texture = null
		ruby_count_label.text = "0"
		ruby_count_label.visible = false

func _on_node_added(node: Node):
	if node is Ruby:
		node.connect("pickup_occurred", _on_pickup_occurred)
	if player and "inventory" in player and node == player:
		player.inventory["rubies"] = 0
		update_inventory()

func _on_pickup_occurred():
	just_picked_up = true
	just_picked_up_timer = 0.2

func get_level_name() -> String:
	match level_type:
		LevelType.LEVEL_ONE:
			return "LevelOne"
		LevelType.LEVEL_TWO:
			return "LevelTwo"
		LevelType.LEVEL_THREE:
			return "LevelThree"
	return "LevelOne"
