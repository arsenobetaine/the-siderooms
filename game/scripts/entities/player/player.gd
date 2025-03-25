class_name Player
extends CharacterBody2D

enum LevelType {
	LEVEL_ONE,
	LEVEL_TWO,
	LEVEL_THREE
}

@export var level_type: LevelType = LevelType.LEVEL_ONE
@export var speed: float = 75.0
@export var speed_multiplier: float = 1.5
@export var max_stamina: float = 2.0
@export var cooldown_duration: float = 3.0
@export var base_energy: float = 1.0
@export var flicker_intensity: float = 0.5
@export var flicker_speed: float = 4.0

var stamina_regen_rate: float = max_stamina / cooldown_duration
var current_stamina: float = max_stamina
var cooldown_timer: float = 0.0
var hide_delay_timer: float = 0.0
var is_sprinting: bool = false
var is_regenerating: bool = false
var current_energy: float = 1.0
var target_energy: float = 1.0
var flicker_timer: float = 0.0
var flicker_interval: float = 0.0
var inventory = { "rubies": 0 }
var is_changing_scene: bool = false
var last_direction: Vector2 = Vector2.DOWN
var current_state: State = State.IDLE

const HIDE_DELAY: float = 0.5
const DELAY_DURATION: float = 1.0
const FADE_IN_DURATION: float = 2.0
const RUBY_SCENE = preload("res://scenes/entities/items/ruby.tscn")

enum State {IDLE, WALKING}

@onready var animation_player: AnimationPlayer = $AnimatedSprite/AnimationPlayer
@onready var point_light: PointLight2D = $PointLight
@onready var sprint_indicator: ProgressBar = $SprintIndicator
@onready var ray_cast: RayCast2D = $RayCast

var is_delaying: bool = true
var delay_timer: float = 0.0
var is_fading_in: bool = false
var fade_in_timer: float = 0.0

func _ready():
	add_to_group("player")
	animation_player.play("idle_down")
	current_energy = 0.0
	target_energy = base_energy
	point_light.energy = current_energy
	_set_next_flicker_interval()
	sprint_indicator.max_value = 100.0
	sprint_indicator.value = (current_stamina / max_stamina) * 100.0
	sprint_indicator.step = 0.0
	sprint_indicator.visible = false

func _physics_process(delta):
	var input_vector = _get_input_vector()
	_handle_sprint(delta, input_vector)
	
	var current_speed = speed * (speed_multiplier if is_sprinting else 1.0)
	velocity = input_vector * current_speed
	move_and_slide()
	
	_update_state(input_vector)
	_update_animation()
	_update_light(delta)
	sprint_indicator.value = (current_stamina / max_stamina) * 100.0
	
	_handle_interactions()

func _get_input_vector() -> Vector2:
	var input_vector = Vector2(
		Input.get_axis("A", "D"),
		Input.get_axis("W", "S")
	)
	if input_vector:
		input_vector = input_vector.normalized()
		last_direction = input_vector
	elif last_direction == Vector2.ZERO:
		last_direction = Vector2.DOWN
	return input_vector

func _handle_sprint(delta: float, input_vector: Vector2):
	if is_regenerating:
		cooldown_timer -= delta
		current_stamina = min(max_stamina, current_stamina + stamina_regen_rate * delta)
		if is_equal_approx(current_stamina, max_stamina):
			is_regenerating = false
			hide_delay_timer = HIDE_DELAY
		if cooldown_timer <= 0:
			cooldown_timer = 0.0
	
	if hide_delay_timer > 0:
		hide_delay_timer -= delta
		if hide_delay_timer <= 0:
			sprint_indicator.visible = false
	
	if Input.is_key_pressed(KEY_SHIFT) and current_stamina > 0 and input_vector:
		if current_stamina > delta:
			is_sprinting = true
			current_stamina -= delta
			sprint_indicator.visible = true
			is_regenerating = false
			cooldown_timer = 0.0
		else:
			is_sprinting = false
			current_stamina = 0.0
			_start_regeneration()
	else:
		is_sprinting = false
		if current_stamina < max_stamina and not is_regenerating:
			_start_regeneration()

func _start_regeneration():
	is_regenerating = true
	cooldown_timer = (max_stamina - current_stamina) / stamina_regen_rate
	sprint_indicator.visible = true

func _update_state(input_vector: Vector2):
	current_state = State.IDLE
	if input_vector and velocity.length() > 1.0:
		var is_blocked = false
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_normal().dot(input_vector) < -0.7:
				is_blocked = true
				break
		if not is_blocked:
			current_state = State.WALKING

func _update_animation():
	var direction_string = _get_direction_string()
	var state_string = "idle" if current_state == State.IDLE else "walk"
	var animation_name = state_string + "_" + direction_string
	
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)
	animation_player.speed_scale = speed_multiplier if current_state == State.WALKING and is_sprinting else 1.0

func _get_direction_string() -> String:
	if last_direction.y < 0:
		return "up"
	elif last_direction.x < 0:
		return "left"
	elif last_direction.x > 0:
		return "right"
	return "down"

func _update_light(delta: float):
	if is_delaying:
		delay_timer += delta
		current_energy = 0.0
		if delay_timer >= DELAY_DURATION:
			is_delaying = false
			is_fading_in = true
			fade_in_timer = 0.0
	elif is_fading_in:
		fade_in_timer += delta
		var fade_progress = fade_in_timer / FADE_IN_DURATION
		current_energy = lerp(0.0, base_energy, fade_progress)
		if fade_in_timer >= FADE_IN_DURATION:
			is_fading_in = false
			current_energy = base_energy
	else:
		flicker_timer -= delta
		if flicker_timer <= 0:
			target_energy = clamp(base_energy + randf_range(-flicker_intensity, flicker_intensity), 0.2, base_energy)
			_set_next_flicker_interval()
		current_energy = lerp(current_energy, target_energy, 20.0 * delta)
	point_light.energy = current_energy

func _set_next_flicker_interval():
	var base_interval = 1.0 / max(flicker_speed, 0.01)
	flicker_interval = randf_range(base_interval * 0.5, base_interval * 1.5)
	flicker_timer = flicker_interval

func _handle_interactions():
	if Input.is_action_just_pressed("Q"):
		var camera = get_node_or_null("/root/" + get_level_name() + "/Camera")
		var ruby_nearby = get_ruby_nearby()
		if ruby_nearby and ruby_nearby.try_collect(self):
			pass
		elif camera and not camera.just_picked_up and inventory["rubies"] > 0:
			drop_ruby()
	
	if Input.is_key_pressed(KEY_V) and Input.is_action_just_pressed("V"):
		point_light.visible = !point_light.visible

func collect_ruby():
	inventory["rubies"] += 1
	var camera = get_node_or_null("/root/" + get_level_name() + "/Camera")
	if camera:
		camera.update_inventory()

func drop_ruby():
	inventory["rubies"] -= 1
	var new_ruby = RUBY_SCENE.instantiate() as Area2D
	if new_ruby:
		var drop_distance = 16.0 if abs(last_direction.x) > abs(last_direction.y) else 24.0
		var drop_offset = last_direction.normalized() * drop_distance
		
		if ray_cast:
			ray_cast.target_position = last_direction.normalized() * (drop_distance + 8.0)
			ray_cast.force_raycast_update()
			if ray_cast.is_colliding():
				drop_offset = -last_direction.normalized() * drop_distance
		
		var drop_position = global_position + drop_offset
		new_ruby.global_position = drop_position
		new_ruby.start_y = drop_position.y
		var level = get_node_or_null("/root/" + get_level_name())
		if level:
			new_ruby.add_to_group("rubies")
			level.add_child(new_ruby)
	
	var camera = get_node_or_null("/root/" + get_level_name() + "/Camera")
	if camera:
		camera.update_inventory()
	check_ruby_count()

func check_ruby_count():
	if is_changing_scene:
		return
	var total_rubies = get_tree().get_nodes_in_group("rubies").size() + inventory["rubies"]
	if total_rubies < 5:
		is_changing_scene = true
		TransitionManager.start_transition(get_restart_scene_path())

func get_ruby_nearby() -> Ruby:
	var detection_area = get_node_or_null("Area")
	if detection_area and detection_area is Area2D:
		for area in detection_area.get_overlapping_areas():
			if area is Ruby:
				return area
	return null

func get_level_name() -> String:
	match level_type:
		LevelType.LEVEL_ONE:
			return "LevelOne"
		LevelType.LEVEL_TWO:
			return "LevelTwo"
		LevelType.LEVEL_THREE:
			return "LevelThree"
	return "LevelOne"

func get_restart_scene_path() -> String:
	match level_type:
		LevelType.LEVEL_ONE:
			return "res://scenes/levels/level_one.tscn"
		LevelType.LEVEL_TWO:
			return "res://scenes/levels/level_two.tscn"
		LevelType.LEVEL_THREE:
			return "res://scenes/levels/level_three.tscn"
	return "res://scenes/levels/level_one.tscn"
