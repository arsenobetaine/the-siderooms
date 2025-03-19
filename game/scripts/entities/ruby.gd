class_name Ruby
extends Area2D

signal collected
signal pickup_occurred

var is_player_inside: bool = false

@export var float_amplitude: float = 4.0
@export var float_speed: float = 2.0
@onready var start_y: float = global_position.y
var time: float = 0.0

func _ready() -> void:
	visible = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	time += delta * float_speed
	var offset = sin(time) * float_amplitude
	global_position = Vector2(global_position.x, start_y + offset)

func try_collect(player: Player) -> bool:
	if is_player_inside:
		player.collect_ruby()
		emit_signal("collected")
		emit_signal("pickup_occurred")
		queue_free()
		return true
	return false

func _on_body_entered(body: Node) -> void:
	if body is Player:
		is_player_inside = true

func _on_body_exited(body: Node) -> void:
	if body is Player:
		is_player_inside = false
