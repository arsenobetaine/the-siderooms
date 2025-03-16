class_name Enemy
extends CharacterBody2D

@export var speed: float = 4.0
@export var approach_speed: float = 4.0
@export var circle_speed: float = 16.0
@export var circle_radius: float = 256.0
@export var min_circle_distance: float = 12.0
@export var circle_angular_speed: float = 0.0
@export var slow_angular_speed: float = 1.0
@export var random_move_radius: float = 32.0

@onready var raycast: RayCast2D = $"ray-cast"
@onready var player: Node = get_node("/root/level-one/player")
@onready var touch_area: Area2D = $"touch-area"

var angle: float = 0.0
var random_angle: float = 0.0

func _ready() -> void:
	await get_tree().physics_frame
	if touch_area:
		touch_area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var to_player = player.global_position - global_position
	var distance = to_player.length()

	if distance < 2.0:
		random_angle += randf_range(-0.1, 0.1) * delta
		var random_direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
		velocity = random_direction * circle_speed
	else:
		if distance > circle_radius:
			var direction = to_player.normalized()
			raycast.target_position = direction * 32
			raycast.add_exception(player)
			raycast.force_raycast_update()
			if raycast.is_colliding() and global_position.distance_to(raycast.get_collision_point()) < 16.0:
				direction = direction.slide(raycast.get_collision_normal()).normalized()
			raycast.remove_exception(player)
			angle = 0.0
			velocity = direction * approach_speed
		else:
			var direction = to_player.normalized()
			if distance < min_circle_distance:
				direction = (player.global_position - direction * min_circle_distance - global_position).normalized()
				distance = min_circle_distance
				angle += slow_angular_speed * delta
			elif distance > circle_radius:
				direction = (player.global_position - direction * circle_radius - global_position).normalized()
				distance = circle_radius
			angle += circle_angular_speed * delta
			direction = (to_player.normalized().rotated(angle)).normalized()
			velocity = direction * circle_speed

	move_and_slide()

func _on_body_entered(body: Node) -> void:
	if body == self or body != player:
		return
	get_tree().call_deferred("reload_current_scene")
