class_name Ruby
extends Area2D

signal collected
var is_player_inside: bool = false

func _ready():
	visible = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	if is_player_inside and Input.is_action_just_pressed("Q"):
		var player = get_node_or_null("/root/level-one/player")
		if player and player is Player:
			player.inventory["rubies"] += 1
			emit_signal("collected")
			queue_free()

func _on_body_entered(body):
	if body is Player:
		is_player_inside = true

func _on_body_exited(body):
	if body is Player:
		is_player_inside = false
