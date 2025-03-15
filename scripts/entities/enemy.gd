class_name enemy
extends CharacterBody2D

@export var speed: float = 4.0
@export var approach_speed: float = 4.0
@export var circle_speed: float = 16.0
@export var circle_radius: float = 256.0
@export var min_circle_distance: float = 12.0
@export var circle_angular_speed: float = 0.0
@export var slow_angular_speed: float = 1.0
@export var random_move_radius: float = 32.0  # Radius for random movement

@onready var raycast: RayCast2D = $"ray-cast"
@onready var player_enem: Node = get_node("/root/level_one/player")
@onready var touch_area: Area2D = $"touch-area"

var angle: float = 0.0
var random_angle: float = 0.0

func _ready():
	await get_tree().physics_frame
	if touch_area:
		touch_area.body_entered.connect(_on_touch_area_body_entered)
	randomize()  # Seed the random number generator

func _physics_process(delta):
	var to_player = player_enem.global_position - global_position
	var distance = to_player.length()

	if distance < 2.0:
		# Random movement within a circular radius
		random_angle += randf_range(-0.1, 0.1) * delta
		var random_radius = randf_range(0, random_move_radius)
		var random_direction = Vector2(cos(random_angle), sin(random_angle)).normalized()
		velocity = random_direction * circle_speed
	else:
		if distance > circle_radius:
			var direction = to_player.normalized()
			raycast.target_position = direction * 32
			raycast.add_exception(player_enem)
			raycast.force_raycast_update()
			if raycast.is_colliding() and global_position.distance_to(raycast.get_collision_point()) < 16.0:
				direction = direction.slide(raycast.get_collision_normal()).normalized()
			raycast.remove_exception(player_enem)
			angle = 0.0
			velocity = direction * approach_speed
		else:
			var direction = to_player.normalized()
			if distance < min_circle_distance:
				direction = (player_enem.global_position - direction * min_circle_distance - global_position).normalized()
				distance = min_circle_distance
				angle += slow_angular_speed * delta
			elif distance > circle_radius:
				direction = (player_enem.global_position - direction * circle_radius - global_position).normalized()
				distance = circle_radius
			angle += circle_angular_speed * delta
			direction = (to_player.normalized().rotated(angle)).normalized()
			velocity = direction * circle_speed

	move_and_slide()

func _on_touch_area_body_entered(body):
	if body == self or body != player_enem: return
	get_tree().call_deferred("reload_current_scene")
