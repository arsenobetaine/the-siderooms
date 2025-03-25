extends CanvasLayer

@onready var play_button = $ButtonPlay
@onready var quit_button = $ButtonEnd
@onready var fullscreen_button = $ButtonFullscreen
@onready var audio_button = $ButtonAudio
# References to the level background panels
@onready var level_one_panel: Panel = $LevelOne
@onready var level_two_panel: Panel = $LevelTwo
@onready var level_three_panel: Panel = $LevelThree

@export var audio_on_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio.png")
@export var audio_off_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio_disabled.png")
@export var audio_on_hover_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio_hovered.png")
@export var audio_off_hover_texture: Texture2D = preload("res://assets/graphics/ui/buttons/audio_disabled_hovered.png")

var scene_tree: SceneTree

var default_cursor: Texture2D = preload("res://assets/graphics/ui/cursors/default.png")
var point_cursor: Texture2D = preload("res://assets/graphics/ui/cursors/point.png")

var hover_color: Color = Color(0.8, 0.8, 0.8, 1.0)
var normal_color: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	# Set all level panels to invisible by default
	if level_one_panel:
		level_one_panel.visible = false
	if level_two_panel:
		level_two_panel.visible = false
	if level_three_panel:
		level_three_panel.visible = false
	
	# Determine the current scene and show the corresponding panel
	var current_scene_path = get_tree().current_scene.scene_file_path
	if current_scene_path:
		var scene_name = current_scene_path.get_file()  # Extracts the file name (e.g., "level_one.tscn")
		if scene_name == "level_one.tscn" and level_one_panel:
			level_one_panel.visible = true
		elif scene_name == "level_two.tscn" and level_two_panel:
			level_two_panel.visible = true
		elif scene_name == "level_three.tscn" and level_three_panel:
			level_three_panel.visible = true
	
	# Existing _ready() logic
	set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)
	scene_tree = get_tree()
	
	play_button.button_up.connect(_handle_play)
	quit_button.button_up.connect(_handle_quit)
	if not fullscreen_button.pressed.is_connected(_handle_fullscreen):
		fullscreen_button.pressed.connect(_handle_fullscreen)
	if not audio_button.pressed.is_connected(_handle_audio):
		audio_button.pressed.connect(_handle_audio)
	
	_connect_button_hover_signals(play_button)
	_connect_button_hover_signals(quit_button)
	_connect_button_hover_signals(fullscreen_button)
	_connect_button_hover_signals(audio_button)
	
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
	TransitionManager.start_transition("res://scenes/utilities/title_screen.tscn")
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

func _handle_website() -> void:
	OS.shell_open("https://the-siderooms.arsenobetaine.dev")

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
