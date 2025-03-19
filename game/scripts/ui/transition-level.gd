class_name TransitionLevel
extends Node2D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await get_tree().create_timer(2.0).timeout
	TransitionManager.start_transition("res://scenes/levels/level-one.tscn")
