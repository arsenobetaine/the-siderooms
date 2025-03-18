class_name TitleScreen
extends Control

@onready var play_button = $"buttons/play-button"
@onready var quit_button = $"buttons/quit-button"
@onready var fullscreen_button = $"top-right/side-buttons/fullscreen-button"
@onready var website_button = $"bottom-right/side-buttons/website-button"
var scene_tree: SceneTree

func _ready() -> void:
	scene_tree = get_tree()
	play_button.button_up.connect(_handle_play)
	quit_button.button_up.connect(_handle_quit)
	if not fullscreen_button.pressed.is_connected(_handle_fullscreen):
		fullscreen_button.pressed.connect(_handle_fullscreen)
	if not website_button.pressed.is_connected(_handle_website):
		website_button.pressed.connect(_handle_website)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _handle_play() -> void:
	call_deferred("_deferred_change_scene")

func _deferred_change_scene() -> void:
	start_transition()

func _handle_quit() -> void:
	if OS.get_name() == "HTML5":
		if JavaScriptBridge:
			JavaScriptBridge.eval("if (typeof closeTab === 'function') closeTab();")
		else:
			OS.shell_open("about:blank")
	else:
		get_tree().quit()

func _handle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func start_transition() -> void:
	TransitionManager.start_transition("res://scenes/levels/level-one.tscn")

func _handle_website() -> void:
	OS.shell_open("https://the-siderooms.arsenobetaine.dev")
