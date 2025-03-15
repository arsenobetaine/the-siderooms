class_name Player
extends CharacterBody2D

# Movement properties
@export var speed: float = 75.0  # Base movement speed in pixels per second
@export var speed_multiplier: float = 1.5  # Speed multiplier when sprinting

# Stamina properties
@export var max_stamina: float = 2.0  # Maximum sprint duration in seconds
@export var cooldown_duration: float = 3.0  # Cooldown duration after sprinting
var stamina_regen_rate: float = max_stamina / cooldown_duration  # Stamina regeneration rate
var current_stamina: float = max_stamina  # Current stamina level
var cooldown_timer: float = 0.0  # Timer for stamina regeneration cooldown
var hide_delay_timer: float = 0.0  # Timer for hiding sprint indicator after full stamina
var is_sprinting: bool = false  # Whether the player is currently sprinting
var is_regenerating: bool = false  # Whether stamina is regenerating
const HIDE_DELAY: float = 0.5  # Delay before hiding sprint indicator after full stamina

# Lighting properties
@export var base_energy: float = 1.0  # Base light energy level
@export var flicker_intensity: float = 0.5  # Intensity of light flickering
@export var flicker_speed: float = 4.0  # Speed of light flickering
var current_energy: float = 1.0  # Current light energy level
var target_energy: float = 1.0  # Target light energy level for flickering
var flicker_timer: float = 0.0  # Timer for next flicker
var flicker_interval: float = 0.0  # Interval between flickers

# Animation and state
enum State {IDLE, WALKING}
var last_direction: Vector2 = Vector2.DOWN  # Last movement direction for animations
var current_state: State = State.IDLE  # Current player state (idle or walking)

# Node references
@onready var animation_player: AnimationPlayer = $"animated-sprite/animation-player"
@onready var point_light: PointLight2D = $"point-light"
@onready var sprint_indicator: ProgressBar = $"sprint-indicator"

func _ready() -> void:
	animation_player.play("idle_down")
	current_energy = base_energy
	target_energy = base_energy
	point_light.energy = current_energy
	_set_next_flicker_interval()
	sprint_indicator.max_value = max_stamina
	sprint_indicator.value = current_stamina
	sprint_indicator.visible = false

func _physics_process(delta: float) -> void:
	# Handle movement input
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_axis("A", "D")
	input_vector.y = Input.get_axis("W", "S")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	
	# Update sprinting and movement
	_handle_sprint(delta)
	var current_speed: float = speed * (speed_multiplier if is_sprinting else 1.0)
	velocity = input_vector * current_speed
	move_and_slide()
	
	# Update state based on movement
	current_state = State.IDLE
	if input_vector != Vector2.ZERO:
		var is_blocked: bool = false
		for i in get_slide_collision_count():
			var collision: KinematicCollision2D = get_slide_collision(i)
			if collision.get_normal().dot(input_vector) < -0.7:
				is_blocked = true
				break
		if not is_blocked and velocity.length() > 1.0:
			current_state = State.WALKING
	
	# Update animations and lighting
	update_animation()
	_update_light(delta)

func _handle_sprint(delta: float) -> void:
	# Handle stamina regeneration
	if is_regenerating:
		cooldown_timer -= delta
		current_stamina = min(max_stamina, current_stamina + stamina_regen_rate * delta)
		sprint_indicator.value = current_stamina
		if is_equal_approx(current_stamina, max_stamina):
			is_regenerating = false
			hide_delay_timer = HIDE_DELAY
		if cooldown_timer <= 0:
			cooldown_timer = 0.0
	
	# Handle hiding sprint indicator after delay
	if hide_delay_timer > 0:
		hide_delay_timer -= delta
		if hide_delay_timer <= 0:
			sprint_indicator.visible = false
	
	# Handle sprint input
	if Input.is_key_pressed(KEY_SHIFT) and current_stamina > 0:
		if current_stamina > delta:
			is_sprinting = true
			current_stamina -= delta
			sprint_indicator.value = current_stamina
			sprint_indicator.visible = true
			is_regenerating = false
			cooldown_timer = 0.0
		else:
			is_sprinting = false
			current_stamina = 0.0
			sprint_indicator.value = current_stamina
			_start_regeneration()
	else:
		is_sprinting = false
		if current_stamina < max_stamina and not is_regenerating:
			_start_regeneration()

func _start_regeneration() -> void:
	is_regenerating = true
	cooldown_timer = (max_stamina - current_stamina) / stamina_regen_rate
	sprint_indicator.visible = true

func update_animation() -> void:
	# Determine direction string for animation
	var direction_string: String = "down"
	if last_direction.y < 0:
		direction_string = "up"
	elif last_direction.x < 0:
		direction_string = "left"
	elif last_direction.x > 0:
		direction_string = "right"
	
	# Determine state string and play animation
	var state_string: String = "idle" if current_state == State.IDLE else "walk"
	var animation_name: String = state_string + "_" + direction_string
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)

func _update_light(delta: float) -> void:
	# Update light flickering
	flicker_timer -= delta
	if flicker_timer <= 0:
		target_energy = clamp(base_energy + randf_range(-flicker_intensity, flicker_intensity), 0.2, base_energy)
		_set_next_flicker_interval()
	
	current_energy = lerp(current_energy, target_energy, 20.0 * delta)
	point_light.energy = current_energy

func _set_next_flicker_interval() -> void:
	var base_interval: float = 1.0 / max(flicker_speed, 0.01)
	flicker_interval = randf_range(base_interval * 0.5, base_interval * 1.5)
	flicker_timer = flicker_interval
