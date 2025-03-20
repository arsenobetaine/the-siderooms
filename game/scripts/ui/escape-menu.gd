extends CanvasLayer

@onready var play_button = $"play-button"
@onready var quit_button = $"quit-button"
@onready var fullscreen_button = $"fullscreen-button"
@onready var audio_button = $"audio-button"
@export var audio_on_texture: Texture2D = preload("res://assets/keys/audio-button.png")
@export var audio_off_texture: Texture2D = preload("res://assets/keys/audio-button-disabled.png")
@export var audio_on_hover_texture: Texture2D = preload("res://assets/keys/audio-button-hovered.png")
@export var audio_off_hover_texture: Texture2D = preload("res://assets/keys/audio-button-disabled-hovered.png")
var scene_tree: SceneTree

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	scene_tree = get_tree()
	play_button.button_up.connect(_handle_play)
	quit_button.button_up.connect(_handle_quit)
	if not fullscreen_button.pressed.is_connected(_handle_fullscreen):
		fullscreen_button.pressed.connect(_handle_fullscreen)
	if not audio_button.pressed.is_connected(_handle_audio):
		audio_button.pressed.connect(_handle_audio)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	audio_button.toggle_mode = false
	update_audio_button()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_parent().toggle_menu()
		if visible:
			update_audio_button()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	pass

func _handle_play() -> void:
	call_deferred("_deferred_change_scene")

func _deferred_change_scene() -> void:
	if visible:
		get_parent().toggle_menu()
		get_viewport().set_input_as_handled()

func _handle_quit() -> void:
	TransitionManager.start_transition("res://scenes/levels/title-screen.tscn")
	get_tree().paused = false

func _handle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _handle_audio() -> void:
	AudioManager.toggle_mute()
	AudioManager.ensure_playing()
	update_audio_button()

func update_audio_button() -> void:
	var is_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	audio_button.texture_normal = audio_off_texture if is_muted else audio_on_texture
	audio_button.texture_hover = audio_off_hover_texture if is_muted else audio_on_hover_texture

func start_transition() -> void:
	TransitionManager.start_transition("res://scenes/levels/level-one.tscn")

func _handle_website() -> void:
	OS.shell_open("https://the-siderooms.arsenobetaine.dev")
