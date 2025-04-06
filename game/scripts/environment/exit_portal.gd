class_name ExitPortal
extends Area2D

enum PortalType {
	LEVEL_ONE,
	LEVEL_TWO,
	LEVEL_THREE
}

@export var portal_type: PortalType = PortalType.LEVEL_ONE
@onready var animated_sprite = $AnimatedSprite
@onready var glow_light = $PointLight
@export var glow_distance: float = 200.0
@export var fade_duration: float = 0.25

var is_glowing: bool = false
var base_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)
var is_changing_scene: bool = false
var player_in_range: bool = false
var player_light: PointLight2D = null
var player_original_energy: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if animated_sprite and not animated_sprite.is_playing():
		animated_sprite.play("portal")
	if glow_light:
		glow_light.energy = 0.0

func _process(_delta: float) -> void:
	if animated_sprite and not animated_sprite.is_playing():
		animated_sprite.play("portal")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= glow_distance != is_glowing:
			if is_glowing:
				stop_glow()
			else:
				start_glow()
		
		if player_in_range and player_light and is_glowing:
			if player_original_energy == 0.0:
				player_original_energy = player_light.energy
			player_light.energy = 0.0
		elif player_light and not is_glowing and player_original_energy != 0.0:
			player_light.energy = player_original_energy
			player_original_energy = 0.0

func start_glow() -> void:
	is_glowing = true
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1.1, 1.1, 1.0, 1.0), fade_duration).from(base_modulate)
	if glow_light:
		tween.parallel().tween_property(glow_light, "energy", 1.0, fade_duration).from(0.0)

func stop_glow() -> void:
	is_glowing = false
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", base_modulate, fade_duration)
	if glow_light:
		tween.parallel().tween_property(glow_light, "energy", 0.0, fade_duration)

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_changing_scene:
		player_in_range = true
		player_light = body.get_node("PointLight") as PointLight2D
		var player = body as Player
		if player and "inventory" in player:
			if player.inventory["rubies"] == 5:
				player.inventory["rubies"] = 0
				is_changing_scene = true
				var next_scene_path = get_next_scene_path()
				if portal_type == PortalType.LEVEL_THREE:
					GameStateManager.set_game_state("win")
				TransitionManager.start_transition(next_scene_path)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		if player_light and player_original_energy != 0.0:
			player_light.energy = player_original_energy
			player_original_energy = 0.0
		player_light = null

func get_next_scene_path() -> String:
	match portal_type:
		PortalType.LEVEL_ONE:
			return "res://scenes/levels/level_two.tscn"
		PortalType.LEVEL_TWO:
			return "res://scenes/levels/level_three.tscn"
		PortalType.LEVEL_THREE:
			return "res://scenes/utilities/title_screen.tscn"
	return "res://scenes/levels/level_two.tscn"

func _change_scene() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
