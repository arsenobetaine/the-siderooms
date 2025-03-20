class_name TitleScreen
extends Control

@onready var play_button = $"canvas-layer/play-button"
@onready var audio_button = $"canvas-layer/audio-button"
@onready var fullscreen_button = $"canvas-layer/fullscreen-button"
@onready var website_button = $"canvas-layer/website-button"
@export var audio_on_texture: Texture2D = preload("res://assets/keys/audio-button.png")
@export var audio_off_texture: Texture2D = preload("res://assets/keys/audio-button-disabled.png")
@export var audio_on_hover_texture: Texture2D = preload("res://assets/keys/audio-button-hovered.png")
@export var audio_off_hover_texture: Texture2D = preload("res://assets/keys/audio-button-disabled-hovered.png")
var scene_tree: SceneTree

func _ready() -> void:
	scene_tree = get_tree()
	play_button.button_up.connect(_handle_play)
	if not audio_button.pressed.is_connected(_handle_audio):
		audio_button.pressed.connect(_handle_audio)
	if not fullscreen_button.pressed.is_connected(_handle_fullscreen):
		fullscreen_button.pressed.connect(_handle_fullscreen)
	if not website_button.pressed.is_connected(_handle_website):
		website_button.pressed.connect(_handle_website)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	audio_button.toggle_mode = false
	var is_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	audio_button.texture_normal = audio_on_texture if not is_muted else audio_on_texture
	audio_button.texture_hover = audio_on_hover_texture if not is_muted else audio_on_hover_texture

func _handle_play() -> void:
	call_deferred("_deferred_change_scene")

func _deferred_change_scene() -> void:
	var was_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	var was_playing = AudioManager.playing
	var playback_position = AudioManager.get_playback_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	TransitionManager.start_transition("res://scenes/ui/transition-level.tscn")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), was_muted)
	if was_playing and not AudioManager.playing:
		AudioManager.play(playback_position)

func _handle_audio() -> void:
	AudioManager.toggle_mute()
	var is_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	audio_button.texture_normal = audio_off_texture if is_muted else audio_on_texture
	audio_button.texture_hover = audio_off_hover_texture if is_muted else audio_on_hover_texture

func _handle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _handle_website() -> void:
	OS.shell_open("https://the-siderooms.arsenobetaine.dev")
