class_name player
extends CharacterBody2D

@export var speed = 200.0
@onready var animation_player = $"animated-sprite/animation-player"  # Assuming AnimatedSprite is the parent node
@onready var point_light = $"point-light"  # Updated to match typical Godot naming

enum State {IDLE, WALKING}
var last_direction = Vector2.DOWN
var current_state = State.IDLE

@export var base_energy: float = 1.0
@export var flicker_intensity: float = 0.5
@export var flicker_speed: float = 4.0

var flicker_timer: float = 0.0
var flicker_interval: float = 0.0
var current_energy: float = 1.0
var target_energy: float = 1.0

func _ready():
	animation_player.play("idle_down")

	if point_light:
		current_energy = base_energy
		target_energy = base_energy
		point_light.energy = current_energy
		_set_next_flicker_interval()

# Rest of the script remains unchanged
func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("A", "D")
	input_vector.y = Input.get_axis("W", "S")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	
	velocity = input_vector * speed
	move_and_slide()
	
	if input_vector != Vector2.ZERO:
		var is_blocked = false
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			if normal.dot(input_vector) < -0.7: 
				is_blocked = true
				break
		
		if not is_blocked and velocity.length() > 1.0:
			current_state = State.WALKING
		else:
			current_state = State.IDLE
	else:
		current_state = State.IDLE
	
	update_animation()

	if point_light:
		flicker_timer -= delta
		if flicker_timer <= 0:
			var flicker_amount = randf_range(-flicker_intensity, flicker_intensity)
			target_energy = base_energy + flicker_amount
			target_energy = clamp(target_energy, 0.2, base_energy)
			_set_next_flicker_interval()
		
		current_energy = lerp(current_energy, target_energy, 20.0 * delta)
		point_light.energy = current_energy

func update_animation():
	var direction_string = ""
	
	if last_direction.y < 0:
		direction_string = "up"
	elif last_direction.x < 0:
		direction_string = "left"
	elif last_direction.y > 0:
		direction_string = "down"
	elif last_direction.x > 0:
		direction_string = "right"
	
	var state_string = ""
	match current_state:
		State.IDLE:
			state_string = "idle"
		State.WALKING:
			state_string = "walk"
	
	var animation_name = state_string + "_" + direction_string
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

func _set_next_flicker_interval() -> void:
	var base_interval = 1.0 / max(flicker_speed, 0.01)
	flicker_interval = randf_range(base_interval * 0.5, base_interval * 1.5)
	flicker_timer = flicker_interval
