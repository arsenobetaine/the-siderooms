class_name Enemy
extends CharacterBody2D

enum EnemyType { ENEMY_ONE, ENEMY_TWO, ENEMY_THREE }
@export var enemy_type: EnemyType = EnemyType.ENEMY_ONE

@export var next_scene_path: String = ""
@export var wander_radius: float = 32.0
@export var wander_speed: float = 20.0
@export var chase_speed: float = 50.0
@export var detection_range: float = 100.0
@export var player_path: NodePath = "Entities/Player"

@onready var player: Node2D = get_node_or_null(player_path)
@onready var touch_area: Area2D = $TouchArea
@onready var wait_timer: Timer = $WaitTimer
@onready var start_position: Vector2 = global_position
@onready var animation_player: AnimationPlayer = $AnimatedSprite/AnimationPlayer

enum State { WANDERING, CHASING, CHASING_PLAYER, CHASING_RUBY, WAITING }
var current_state: State = State.WANDERING
var target_position: Vector2 = Vector2.ZERO
var target_ruby: Node = null
var to_ruby: Vector2 = Vector2.ZERO
var distance_to_ruby: float = INF

enum AnimationState { IDLE, WALKING }
var last_direction: Vector2 = Vector2.DOWN
var current_animation_state: AnimationState = AnimationState.IDLE

const TITLE_SCREEN_PATH: String = "res://scenes/utilities/title_screen.tscn"

func _ready() -> void:
	add_to_group("enemies")
	await get_tree().physics_frame
	
	if not player:
		var current_scene = get_tree().current_scene
		if current_scene:
			player = current_scene.get_node_or_null("Entities/Player")
	
	if touch_area:
		touch_area.body_entered.connect(_on_body_entered)
		if enemy_type == EnemyType.ENEMY_ONE:
			touch_area.area_entered.connect(_on_area_entered)
		touch_area.monitoring = true
		touch_area.monitorable = true
	
	wait_timer.wait_time = 2.0
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_wait_timeout)
	_set_random_target()
	animation_player.play("one_idle_down")

func _physics_process(_delta: float) -> void:
	if not player:
		return
	
	var to_player = player.global_position - global_position
	var distance_to_player = to_player.length()
	
	# Base scale is 2.0, so calculate the scale factor relative to that
	var base_scale: float = 2.0
	var scale_factor: float = scale.x / base_scale  # Assuming uniform scaling (scale.x == scale.y)
	
	# Adjust detection range based on scale factor
	var adjusted_detection_range: float = detection_range * scale_factor
	var effective_detection_range: float = adjusted_detection_range if player.point_light.visible else adjusted_detection_range * 0.5
	
	# Increase detection range by 1.5x when player is sprinting (from previous change)
	if player.is_sprinting:
		effective_detection_range *= 1.5
	
	if enemy_type == EnemyType.ENEMY_ONE:
		var ruby_count = player.inventory.get("rubies", 0) if player.inventory else 0
		
		target_ruby = _get_nearest_ruby()
		if target_ruby:
			to_ruby = target_ruby.global_position - global_position
			distance_to_ruby = to_ruby.length()
			if distance_to_ruby < 5.0 and current_state == State.CHASING_RUBY:
				_collect_ruby(target_ruby)
		else:
			to_ruby = Vector2.ZERO
			distance_to_ruby = INF
		
		if distance_to_player < effective_detection_range and ruby_count > 0:
			current_state = State.CHASING_PLAYER
			target_ruby = null
		elif target_ruby and distance_to_ruby < effective_detection_range:
			current_state = State.CHASING_RUBY
		elif (distance_to_player > effective_detection_range * 1.5 or ruby_count == 0) and not target_ruby:
			if current_state in [State.CHASING_PLAYER, State.CHASING_RUBY]:
				current_state = State.WANDERING
				_set_random_target()
	
	else:
		if distance_to_player < effective_detection_range:
			current_state = State.CHASING
		elif distance_to_player > effective_detection_range * 1.5:
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
		State.CHASING_PLAYER:
			velocity = to_player.normalized() * chase_speed
		State.CHASING_RUBY:
			if is_instance_valid(target_ruby):
				velocity = to_ruby.normalized() * chase_speed
			else:
				current_state = State.WANDERING
				target_ruby = null
				_set_random_target()
		State.WAITING:
			velocity = Vector2.ZERO
	
	move_and_slide()
	if current_state == State.WANDERING:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is TileMapLayer:
				var tile_map = collider as TileMapLayer
				var tile_pos = tile_map.local_to_map(tile_map.to_local(collision.get_position()))
				var tile_data = tile_map.get_cell_tile_data(tile_pos)
				if tile_data and tile_data.get_collision_polygons_count(0) > 0:
					target_position = start_position
					break
			elif collider is Enemy and collider != self:
				target_position = start_position
				break
	
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
	
	match enemy_type:
		EnemyType.ENEMY_ONE:
			player.inventory["rubies"] = 0
			var camera = get_tree().current_scene.get_node_or_null("Camera")
			if camera:
				camera.update_inventory()
			player.check_ruby_count()
		EnemyType.ENEMY_TWO:
			var current_scene_path = get_tree().current_scene.scene_file_path
			if current_scene_path:
				TransitionManager.start_transition(current_scene_path)
		EnemyType.ENEMY_THREE:
			if ResourceLoader.exists(TITLE_SCREEN_PATH):
				GameStateManager.set_game_state("lose")
				TransitionManager.start_transition(TITLE_SCREEN_PATH)

func _on_area_entered(area: Area2D) -> void:
	if enemy_type == EnemyType.ENEMY_ONE and area.is_in_group("rubies") and area is Ruby:
		_collect_ruby(area)

func _collect_ruby(ruby: Node) -> void:
	if is_instance_valid(ruby):
		ruby.remove_from_group("rubies")
		ruby.queue_free()
	target_ruby = null
	current_state = State.WANDERING
	_set_random_target()
	if player:
		await get_tree().process_frame
		player.check_ruby_count()

func _get_nearest_ruby() -> Node:
	if enemy_type != EnemyType.ENEMY_ONE:
		return null
		
	var rubies = get_tree().get_nodes_in_group("rubies")
	var nearest_ruby: Node = null
	var min_distance: float = INF
	
	# Adjust detection range based on scale
	var base_scale: float = 2.0
	var scale_factor: float = scale.x / base_scale
	var adjusted_detection_range: float = detection_range * scale_factor
	var effective_detection_range: float = adjusted_detection_range if player.point_light.visible else adjusted_detection_range * 0.5
	
	for ruby in rubies:
		if not is_instance_valid(ruby):
			continue
		var distance = global_position.distance_to(ruby.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_ruby = ruby
	
	return nearest_ruby if min_distance < effective_detection_range else null

func start_transition() -> void:
	if next_scene_path:
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
	
	var type_prefix: String = "one_"
	match enemy_type:
		EnemyType.ENEMY_ONE:
			type_prefix = "one_"
		EnemyType.ENEMY_TWO:
			type_prefix = "two_"
		EnemyType.ENEMY_THREE:
			type_prefix = "three_"
	
	var animation_name: String = type_prefix + state_string + "_" + direction_string
	if animation_player.current_animation != animation_name:
		animation_player.play(animation_name)
