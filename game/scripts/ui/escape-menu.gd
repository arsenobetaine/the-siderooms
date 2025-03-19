extends CanvasLayer

@onready var play_button = $"play-button"
@onready var quit_button = $"quit-button"
@onready var fullscreen_button = $"fullscreen-button"
@onready var website_button = $"website-button"
var scene_tree: SceneTree

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	scene_tree = get_tree()
	play_button.button_up.connect(_handle_play)
	quit_button.button_up.connect(_handle_quit)
	if not fullscreen_button.pressed.is_connected(_handle_fullscreen):
		fullscreen_button.pressed.connect(_handle_fullscreen)
	if not website_button.pressed.is_connected(_handle_website):
		website_button.pressed.connect(_handle_website)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_parent().toggle_menu()
		get_viewport().set_input_as_handled()

func _handle_play() -> void:
	call_deferred("_deferred_change_scene")

func _deferred_change_scene() -> void:
	if visible:
		get_parent().toggle_menu()
		get_viewport().set_input_as_handled()

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
