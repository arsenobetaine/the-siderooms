class_name player
extends CharacterBody2D

@export var speed = 200.0
@export var base_energy: float = 1.0
@export var flicker_intensity: float = 0.5
@export var flicker_speed: float = 4.0

@onready var animation_player = $"animated-sprite/animation-player"
@onready var point_light = $"point-light"
@onready var sprint_indicator = $"sprint-indicator"

enum State {IDLE, WALKING}
var last_direction = Vector2.DOWN
var current_state = State.IDLE
var current_energy: float = 1.0
var target_energy: float = 1.0
var flicker_timer: float = 0.0
var flicker_interval: float = 0.0

var sprint_multiplier: float = 1.5
var sprint_duration: float = 2.0
var sprint_cooldown: float = 3.0
var sprint_timer: float = 0.0
var cooldown_timer: float = 0.0
var is_sprinting: bool = false

func _ready():
	animation_player.play("idle_down")
	current_energy = base_energy
	target_energy = base_energy
	point_light.energy = current_energy
	_set_next_flicker_interval()
	sprint_indicator.visible = false

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("A", "D")
	input_vector.y = Input.get_axis("W", "S")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	
	_handle_sprint(delta)
	var current_speed = speed * (sprint_multiplier if is_sprinting else 1.0)
	velocity = input_vector * current_speed
	move_and_slide()
	
	current_state = State.IDLE
	if input_vector != Vector2.ZERO:
		var is_blocked = false
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_normal().dot(input_vector) < -0.7:
				is_blocked = true
				break
		if not is_blocked and velocity.length() > 1.0:
			current_state = State.WALKING
	
	update_animation()
	
	flicker_timer -= delta
	if flicker_timer <= 0:
		target_energy = clamp(base_energy + randf_range(-flicker_intensity, flicker_intensity), 0.2, base_energy)
		_set_next_flicker_interval()
	
	current_energy = lerp(current_energy, target_energy, 20.0 * delta)
	point_light.energy = current_energy

func _handle_sprint(delta):
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	if Input.is_key_pressed(KEY_SHIFT) and cooldown_timer <= 0:
		if sprint_timer < sprint_duration:
			is_sprinting = true
			sprint_timer += delta
			sprint_indicator.visible = true
			sprint_indicator.value = sprint_duration - sprint_timer
		else:
			is_sprinting = false
			cooldown_timer = sprint_cooldown
			sprint_timer = 0.0
			sprint_indicator.visible = false
	else:
		is_sprinting = false
		if sprint_timer > 0 and cooldown_timer <= 0:
			cooldown_timer = sprint_cooldown
			sprint_timer = 0.0
		sprint_indicator.visible = false
		sprint_indicator.value = 0.0

func update_animation():
	var direction_string = "down"
	if last_direction.y < 0:
		direction_string = "up"
	elif last_direction.x < 0:
		direction_string = "left"
	elif last_direction.x > 0:
		direction_string = "right"
	
	var state_string = "idle" if current_state == State.IDLE else "walk"
	var animation_name = state_string + "_" + direction_string
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

func _set_next_flicker_interval():
	var base_interval = 1.0 / max(flicker_speed, 0.01)
	flicker_interval = randf_range(base_interval * 0.5, base_interval * 1.5)
	flicker_timer = flicker_interval
