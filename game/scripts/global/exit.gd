class_name Exit
extends Area2D

@export var next_scene_path: String = "res://scenes/levels/title-screen.tscn"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		call_deferred("_change_scene")

func _change_scene() -> void:
	get_tree().change_scene_to_file(next_scene_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
