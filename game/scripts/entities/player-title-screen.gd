class_name PlayerTitleScreen
extends CharacterBody2D

@export var base_energy: float = 1.0
@export var flicker_intensity: float = 0.5
@export var flicker_speed: float = 4.0
@export var gravity: float = 980.0  # Gravity strength (pixels/sec^2)
var current_energy: float = 1.0
var target_energy: float = 1.0
var flicker_timer: float = 0.0
var flicker_interval: float = 0.0
var inventory = { "rubies": 0 }
@onready var animation_player: AnimationPlayer = $"animated-sprite/animation-player"
@onready var point_light: PointLight2D = $"point-light"
@onready var ray_cast: RayCast2D = $"ray-cast"
const RUBY_SCENE = preload("res://scenes/entities/ruby.tscn")
const TRANSITION_SCENE_PATH = "res://scenes/ui/transition-level.tscn"

func _ready():
	animation_player.get_animation("idle_right").loop_mode = Animation.LOOP_LINEAR
	animation_player.get_animation("idle_left").loop_mode = Animation.LOOP_LINEAR
	current_energy = base_energy
	target_energy = base_energy
	point_light.energy = current_energy
	_set_next_flicker_interval()

func _physics_process(delta):
	# Apply gravity only in the transition scene
	if get_tree().current_scene.scene_file_path == TRANSITION_SCENE_PATH:
		velocity.y += gravity * delta
		move_and_slide()
	else:
		velocity.y = 0  # Reset velocity when not in transition scene
	
	_update_animation()
	_update_light(delta)

func _update_animation():
	var screen_center_x = get_viewport_rect().size.x / 2
	var mouse_x = get_viewport().get_mouse_position().x
	var current_anim = animation_player.current_animation
	
	if mouse_x < screen_center_x and current_anim != "idle_left":
		animation_player.play("idle_left")
	elif mouse_x >= screen_center_x and current_anim != "idle_right":
		animation_player.play("idle_right")

func _update_light(delta):
	flicker_timer -= delta
	if flicker_timer <= 0:
		target_energy = clamp(base_energy + randf_range(-flicker_intensity, flicker_intensity), 0.2, base_energy)
		_set_next_flicker_interval()
	current_energy = lerp(current_energy, target_energy, 20.0 * delta)
	point_light.energy = current_energy

func _set_next_flicker_interval():
	var base_interval: float = 1.0 / max(flicker_speed, 0.01)
	flicker_interval = randf_range(base_interval * 0.5, base_interval * 1.5)
	flicker_timer = flicker_interval

func collect_ruby():
	inventory["rubies"] += 1
	var camera = get_node_or_null("/root/level-one/camera")
	if camera:
		camera.update_inventory()

func drop_ruby():
	inventory["rubies"] -= 1
	var new_ruby = RUBY_SCENE.instantiate() as Area2D
	if new_ruby:
		var drop_distance: float = 16.0
		var drop_offset = Vector2.RIGHT * drop_distance
		
		if ray_cast:
			ray_cast.target_position = Vector2.RIGHT * (drop_distance + 8.0)
			ray_cast.force_raycast_update()
			if ray_cast.is_colliding():
				drop_offset = Vector2.LEFT * drop_distance
		
		var drop_position = global_position + drop_offset
		new_ruby.global_position = drop_position
		new_ruby.start_y = drop_position.y
		var level = get_node_or_null("/root/level-one")
		if level:
			level.add_child(new_ruby)
	
	var camera = get_node_or_null("/root/level-one/camera")
	if camera:
		camera.update_inventory()

func get_ruby_nearby() -> Ruby:
	var detection_area = get_node_or_null("area")
	if detection_area and detection_area is Area2D:
		for area in detection_area.get_overlapping_areas():
			if area is Ruby:
				return area
	return null
