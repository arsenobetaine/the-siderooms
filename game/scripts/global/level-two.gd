class_name LevelTwo
extends Node2D

@onready var escape_menu = $"escape-menu"

func _ready() -> void:
	escape_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_menu()

func toggle_menu() -> void:
	if escape_menu.visible:
		escape_menu.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		escape_menu.visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
