class_name EnemyOne
extends CharacterBody2D

@export var next_scene_path: String = "res://scenes/levels/level-one.tscn"
@export var wander_radius: float = 32.0
@export var wander_speed: float = 20.0
@export var chase_speed: float = 50.0
@export var detection_range: float = 100.0
@onready var player: Node2D = get_node("/root/level-one/entities/player")
@onready var touch_area: Area2D = $"touch-area"
@onready var wait_timer: Timer = $"wait-timer"
@onready var start_position: Vector2 = global_position
@onready var animation_player: AnimationPlayer = $"animated-sprite/animation-player"
enum State { WANDERING, CHASING, WAITING }
var current_state: State = State.WANDERING
var target_position: Vector2 = Vector2.ZERO
enum AnimationState { IDLE, WALKING }
var last_direction: Vector2 = Vector2.DOWN
var current_animation_state: AnimationState = AnimationState.IDLE

func _ready() -> void:
	await get_tree().physics_frame
	if touch_area:
		touch_area.body_entered.connect(_on_body_entered)
	wait_timer.wait_time = 2.0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timeout)
	_set_random_target()
	animation_player.play("idle_down")

func _physics_process(_delta: float) -> void:
	var to_player = player.global_position - global_position
	var distance_to_player = to_player.length()
	var ruby_count = player.inventory.get("rubies", 0) if player.inventory else 0
	
	if distance_to_player < detection_range and ruby_count > 0:
		current_state = State.CHASING
	elif distance_to_player > detection_range * 1.5 or ruby_count == 0:
		if current_state == State.CHASING:
			current_state = State.WANDERING
			_set_random_target()
	
	match current_state:
		State.WANDERING:
			if global_position.distance_to(target_position) < 10.0:
				current_state = State.WAITING
				wait_timer.start()
			else:
				velocity = (target_position - global_position).normalized() * wander_speed
		State.CHASING:
			velocity = to_player.normalized() * chase_speed
		State.WAITING:
			velocity = Vector2.ZERO
	
	move_and_slide()
	_update_animation_state()
	_update_animation()

func _set_random_target() -> void:
	var angle = randf() * 2.0 * PI
	var radius = randf_range(wander_radius * 0.2, wander_radius)
	target_position = start_position + Vector2(cos(angle), sin(angle)) * radius

func _on_wait_timeout() -> void:
	current_state = State.WANDERING
	_set_random_target()

func _on_body_entered(body: Node) -> void:
	if body != player or body == self:
		return
	player.inventory["rubies"] = 0

func start_transition() -> void:
	TransitionManager.start_transition(next_scene_path)

func _update_animation_state() -> void:
	current_animation_state = AnimationState.IDLE
	if velocity.length() > 1.0:
		current_animation_state = AnimationState.WALKING
		last_direction = velocity.normalized()

func _update_animation() -> void:
	var direction_string: String = "down"
	var angle = last_direction.angle()
	
	if abs(angle) < PI / 4 or abs(angle) > 7 * PI / 4:
		direction_string = "right"
	elif abs(angle) > 3 * PI / 4 and abs(angle) < 5 * PI / 4:
		direction_string = "left"
	elif angle > PI / 4 and angle < 3 * PI / 4:
		direction_string = "down"
	elif angle < -PI / 4 and angle > -3 * PI / 4:
		direction_string = "up"
	
	var state_string: String = "idle" if current_animation_state == AnimationState.IDLE else "walk"
	var animation_name: String = state_string + "_" + direction_string
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)
