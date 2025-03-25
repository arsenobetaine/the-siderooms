class_name FallingScene
extends Node2D

@export var follow_speed: float = 15.0
@export var gravity: float = 980.0
@onready var player = $Player
@onready var camera = $Camera
@onready var animation_player: AnimationPlayer = $Player/AnimatedSprite/AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if camera and player:
		camera.position = player.position
	if animation_player:
		animation_player.play("idle_right")
	await get_tree().create_timer(2.0).timeout
	TransitionManager.start_transition("res://scenes/levels/level_one.tscn")

func _process(delta: float) -> void:
	if camera and player:
		var target_position = player.position
		var lerp_factor = 1.0 - exp(-follow_speed * delta)
		camera.position = camera.position.lerp(target_position, lerp_factor)

func _physics_process(delta: float) -> void:
	if player and player is CharacterBody2D:
		player.velocity.y += gravity * delta
		player.move_and_slide()
