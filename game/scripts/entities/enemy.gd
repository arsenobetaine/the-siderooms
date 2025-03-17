class_name Enemy
extends CharacterBody2D

@export var wander_radius: float = 32.0
@export var wander_speed: float = 20.0
@export var chase_speed: float = 50.0
@export var detection_range: float = 100.0

@onready var player: Node2D = get_node("/root/level-one/player")
@onready var touch_area: Area2D = $"touch-area"
@onready var wait_timer: Timer = $"wait-timer"
@onready var start_position: Vector2 = global_position

enum State { WANDERING, CHASING, WAITING }
var current_state: State = State.WANDERING
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	await get_tree().physics_frame
	if touch_area:
		touch_area.body_entered.connect(_on_body_entered)
	wait_timer.wait_time = 2.0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timeout)
	_set_random_target()

func _physics_process(_delta: float) -> void:
	var to_player = player.global_position - global_position
	var distance_to_player = to_player.length()

	if distance_to_player < detection_range:
		current_state = State.CHASING
	elif distance_to_player > detection_range * 1.5:
		if current_state == State.CHASING:
			current_state = State.WANDERING
			_set_random_target()

	match current_state:
		State.WANDERING:
			if global_position.distance_to(target_position) < 10.0:
				current_state = State.WAITING
				wait_timer.start()
			velocity = (target_position - global_position).normalized() * wander_speed
		State.CHASING:
			velocity = to_player.normalized() * chase_speed
		State.WAITING:
			velocity = Vector2.ZERO

	move_and_slide()

func _set_random_target() -> void:
	var angle = randf() * 2.0 * PI
	var radius = randf_range(wander_radius * 0.2, wander_radius)
	target_position = start_position + Vector2(cos(angle), sin(angle)) * radius

func _on_wait_timeout() -> void:
	current_state = State.WANDERING
	_set_random_target()

func _on_body_entered(body: Node) -> void:
	if body == self or body != player:
		return
	get_tree().call_deferred("reload_current_scene")
