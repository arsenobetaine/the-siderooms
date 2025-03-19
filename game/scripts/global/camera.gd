class_name Camera
extends Camera2D

@export var follow_speed: float = 5.0
@export var lookahead_distance: float = 100.0
@onready var player = get_node("/root/level-one/entities/player")
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
@onready var e_key: TextureRect = $"ui/e-key"
@onready var q_key: TextureRect = $"ui/q-key"
@onready var inventory: Control = $ui/inventory
@onready var background: TextureRect = $ui/inventory/background
@onready var slot1: TextureRect = $"ui/inventory/slot-one"
@onready var slot2: TextureRect = $"ui/inventory/slot-two"
@onready var slot3: TextureRect = $"ui/inventory/slot-three"
@onready var ruby_count_label: Label = $"ui/inventory/ruby-count"

var ruby_texture: Texture2D = preload("res://assets/art/ruby.png")
var pressed_color: Color = Color(0.8, 0.8, 0.8, 1)
var just_picked_up: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	position = player.position
	inventory.visible = false
	ruby_count_label.visible = false
	update_inventory()
	get_tree().node_added.connect(_on_node_added)

func _process(delta):
	var target_position = player.position
	var lookahead_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		lookahead_vector.x += 1
		right_key.modulate = pressed_color
	else:
		right_key.modulate = Color.WHITE
	if Input.is_action_pressed("ui_left"):
		lookahead_vector.x -= 1
		left_key.modulate = pressed_color
	else:
		left_key.modulate = Color.WHITE
	if Input.is_action_pressed("ui_down"):
		lookahead_vector.y += 1
		down_key.modulate = pressed_color
	else:
		down_key.modulate = Color.WHITE
	if Input.is_action_pressed("ui_up"):
		lookahead_vector.y -= 1
		up_key.modulate = pressed_color
	else:
		up_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_W):
		w_key.modulate = pressed_color
	else:
		w_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_A):
		a_key.modulate = pressed_color
	else:
		a_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_S):
		s_key.modulate = pressed_color
	else:
		s_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_D):
		d_key.modulate = pressed_color
	else:
		d_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_F11):
		f11_key.modulate = pressed_color
	else:
		f11_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_ESCAPE):
		esc_key.modulate = pressed_color
	else:
		esc_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_SHIFT):
		shift_key.modulate = pressed_color
	else:
		shift_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_E):
		e_key.modulate = pressed_color
		if Input.is_action_just_pressed("E"):
			inventory.visible = !inventory.visible
	else:
		e_key.modulate = Color.WHITE
	if Input.is_key_pressed(KEY_Q):
		q_key.modulate = pressed_color
	else:
		q_key.modulate = Color.WHITE
	
	if inventory.visible:
		update_inventory()
	
	# Apply lookahead vector to target position
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
	await get_tree().create_timer(0.2).timeout
	just_picked_up = false
	update_inventory()
