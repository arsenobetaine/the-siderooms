class_name ExitPortalTwo
extends Area2D

@export var next_scene_path: String = "res://scenes/levels/title-screen.tscn"
@onready var animated_sprite = $"animated-sprite"
@onready var glow_light = $"point-light"
@export var glow_distance: float = 100.0
@export var fade_duration: float = 0.25
var is_glowing: bool = false
var base_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
var is_changing_scene: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if animated_sprite and not animated_sprite.is_playing():
		animated_sprite.play("portal")
	if glow_light:
		glow_light.energy = 0.0

func _process(_delta: float) -> void:
	if animated_sprite and not animated_sprite.is_playing():
		animated_sprite.play("portal")
	var player = get_node_or_null("/root/level-one/entities/player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= glow_distance and not is_glowing:
			start_glow()
		elif distance > glow_distance and is_glowing:
			stop_glow()

func start_glow() -> void:
	is_glowing = true
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1.1, 1.1, 1.0, 1.0), fade_duration).from(base_modulate)
	if glow_light:
		tween.parallel().tween_property(glow_light, "energy", 0.1, fade_duration).from(0.0)

func stop_glow() -> void:
	is_glowing = false
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", base_modulate, fade_duration)
	if glow_light:
		tween.parallel().tween_property(glow_light, "energy", 0.0, fade_duration)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player" and not is_changing_scene:
		var player = body as Player
		if player and "inventory" in player and player.inventory["rubies"] == 3:
			player.inventory["rubies"] = 0
			is_changing_scene = true
			start_transition()

func start_transition() -> void:
	TransitionManager.start_transition(next_scene_path)

func _change_scene() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
