class_name exit
extends Area2D

@export var next_scene_path: String = "res://scenes/levels/the-siderooms.tscn"  # Already correct

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D):
	if body.name == "player":
		call_deferred("_deferred_scene_change")

func _deferred_scene_change():
	get_tree().change_scene_to_file(next_scene_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
