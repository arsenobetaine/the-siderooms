class_name TitleScreen
extends Control

@onready var play_button = $CanvasLayer/ButtonPlay
@onready var audio_button = $CanvasLayer/ButtonAudio
@onready var fullscreen_button = $CanvasLayer/ButtonFullscreen
@onready var website_button = $CanvasLayer/ButtonWebsite
@onready var animation_player: AnimationPlayer = $Background/Player/AnimatedSprite/AnimationPlayer
@onready var point_light: PointLight2D = $Background/Player/PointLight
@onready var title_panel: Panel = $CanvasLayer/Title
@onready var win_panel: Panel = $CanvasLayer/Win
@onready var lose_panel: Panel = $CanvasLayer/Lose

@export var audio_on_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio.png")
@export var audio_off_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio_disabled.png")
@export var audio_on_hover_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio_hovered.png")
@export var audio_off_hover_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio_disabled_hovered.png")
@export var base_energy: float = 1.0
@export var flicker_intensity: float = 0.5
@export var flicker_speed: float = 4.0

var current_energy: float = 1.0
var target_energy: float = 1.0
var flicker_timer: float = 0.0
var flicker_interval: float = 0.0

var default_cursor: Texture2D = preload("res://assets/graphics/ui/cursors/default.png")
var point_cursor: Texture2D = preload("res://assets/graphics/ui/cursors/point.png")

var hover_color: Color = Color(0.8, 0.8, 0.8, 1.0)
var normal_color: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	if title_panel:
		title_panel.visible = false
	if win_panel:
		win_panel.visible = false
	if lose_panel:
		lose_panel.visible = false

	if not (play_button and audio_button and fullscreen_button and website_button):
		return
	
	if not play_button.pressed.is_connected(_handle_play):
		play_button.pressed.connect(_handle_play)
	if not audio_button.pressed.is_connected(_handle_audio):
		audio_button.pressed.connect(_handle_audio)
	if not fullscreen_button.pressed.is_connected(_handle_fullscreen):
		fullscreen_button.pressed.connect(_handle_fullscreen)
	if not website_button.pressed.is_connected(_handle_website):
		website_button.pressed.connect(_handle_website)
	
	_connect_button_hover_signals(play_button)
	_connect_button_hover_signals(audio_button)
	_connect_button_hover_signals(fullscreen_button)
	_connect_button_hover_signals(website_button)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_audio_button()
	
	if animation_player:
		var right_anim = animation_player.get_animation("idle_right")
		var left_anim = animation_player.get_animation("idle_left")
		right_anim.loop_mode = Animation.LOOP_LINEAR
		left_anim.loop_mode = Animation.LOOP_LINEAR
	
	if point_light:
		current_energy = base_energy
		target_energy = base_energy
		point_light.energy = current_energy
		_set_next_flicker_interval()

	update_panel_visibility()

func _process(delta: float) -> void:
	_update_animation()
	_update_light(delta)

func _handle_play() -> void:
	var was_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	var was_playing = false
	var playback_position = 0.0
	
	# Safety check for AudioManager and audio_player
	if AudioManager and AudioManager.has_node("AudioStreamPlayer") and AudioManager.audio_player:
		was_playing = AudioManager.audio_player.playing
		playback_position = AudioManager.audio_player.get_playback_position()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	TransitionManager.start_transition("res://scenes/utilities/falling_scene.tscn")
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), was_muted)
	
	# Only attempt to play if AudioManager.audio_player is valid
	if was_playing and AudioManager and AudioManager.has_node("AudioStreamPlayer") and AudioManager.audio_player and not AudioManager.audio_player.playing:
		AudioManager.audio_player.play(playback_position)

func _handle_audio() -> void:
	AudioManager.toggle_mute()
	_update_audio_button()

func _handle_fullscreen() -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		else DisplayServer.WINDOW_MODE_FULLSCREEN
	)
	if point_light:
		point_light.energy = clamp(current_energy, 0.2, base_energy)

func _handle_website() -> void:
	OS.shell_open("https://the-siderooms.arsenobetaine.dev")

func _update_audio_button() -> void:
	if not audio_button:
		return
	var is_muted = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	audio_button.texture_normal = audio_off_texture if is_muted else audio_on_texture
	audio_button.texture_hover = audio_off_hover_texture if is_muted else audio_on_hover_texture

func _update_animation() -> void:
	if not animation_player:
		return
	var screen_center_x = get_viewport_rect().size.x / 2
	var mouse_x = get_viewport().get_mouse_position().x
	var current_anim = animation_player.current_animation
	if mouse_x < screen_center_x and current_anim != "idle_left":
		animation_player.play("idle_left")
	elif mouse_x >= screen_center_x and current_anim != "idle_right":
		animation_player.play("idle_right")

func _update_light(delta: float) -> void:
	if not point_light:
		return
	flicker_timer -= delta
	if flicker_timer <= 0:
		target_energy = clamp(base_energy + randf_range(-flicker_intensity, flicker_intensity), 0.2, base_energy)
		_set_next_flicker_interval()
	current_energy = lerp(current_energy, target_energy, 20.0 * delta)
	point_light.energy = current_energy
	point_light.energy = clamp(point_light.energy, 0.2, base_energy)

func _set_next_flicker_interval() -> void:
	var base_interval: float = 1.0 / max(flicker_speed, 0.01)
	flicker_interval = randf_range(base_interval * 0.5, base_interval * 1.5)
	flicker_timer = flicker_interval

func _connect_button_hover_signals(button: BaseButton) -> void:
	if not button.mouse_entered.is_connected(_on_button_mouse_entered.bind(button)):
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	if not button.mouse_exited.is_connected(_on_button_mouse_exited.bind(button)):
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

func _on_button_mouse_entered(button: BaseButton) -> void:
	Input.set_custom_mouse_cursor(point_cursor)
	button.modulate = hover_color

func _on_button_mouse_exited(button: BaseButton) -> void:
	Input.set_custom_mouse_cursor(default_cursor)
	button.modulate = normal_color

func _exit_tree() -> void:
	if play_button and play_button.pressed.is_connected(_handle_play):
		play_button.pressed.disconnect(_handle_play)
	if audio_button and audio_button.pressed.is_connected(_handle_audio):
		audio_button.pressed.disconnect(_handle_audio)
	if fullscreen_button and fullscreen_button.pressed.is_connected(_handle_fullscreen):
		fullscreen_button.pressed.disconnect(_handle_fullscreen)
	if website_button and website_button.pressed.is_connected(_handle_website):
		website_button.pressed.disconnect(_handle_website)

func update_panel_visibility() -> void:
	if title_panel and win_panel and lose_panel:
		var state = GameStateManager.get_game_state()
		if state == "win":
			title_panel.visible = false
			win_panel.visible = true
			lose_panel.visible = false
		elif state == "lose":
			title_panel.visible = false
			win_panel.visible = false
			lose_panel.visible = true
		else:
			title_panel.visible = true
			win_panel.visible = false
			lose_panel.visible = false
		GameStateManager.clear_game_state()
