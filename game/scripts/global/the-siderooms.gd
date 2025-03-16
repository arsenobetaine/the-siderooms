class_name the_siderooms
extends Node2D

@onready var play_button = $"buttons/play-button"
@onready var quit_button = $"buttons/quit-button"
@onready var mute_button = $"CanvasLayer/UI/MuteButton"
@onready var fullscreen_button = $CanvasLayer/UI/FullscreenButton
@onready var website_button = $CanvasLayer/UI/WebsiteButton
@onready var title_label = $CanvasLayer/UI/TitleLabel
@onready var random_button = $CanvasLayer/UI/RandomButton
@onready var menu_container = $CanvasLayer/UI/MenuContainer

const REFERENCE_RESOLUTION = Vector2(1280, 720)

func _ready():
	play_button.button_up.connect(_on_play_pressed)
	quit_button.button_up.connect(_on_quit_pressed)
	mute_button.toggled.connect(_on_mute_toggled)
	fullscreen_button.toggled.connect(_on_fullscreen_pressed)
	website_button.button_up.connect(_on_website_pressed)
	await get_tree().process_frame
	adjust_ui_to_resolution()

# Rest of the script remains unchanged
func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		adjust_ui_to_resolution()

func adjust_ui_to_resolution():
	var viewport_size = get_viewport().size
	var ui_scale = min(float(viewport_size.x) / REFERENCE_RESOLUTION.x, float(viewport_size.y) / REFERENCE_RESOLUTION.y)
	
	if title_label:
		var font = title_label.get("custom_fonts/font")
		if font:
			font.size = int(48 * ui_scale)
		title_label.size = Vector2(400, 50) * ui_scale
		title_label.position = Vector2((viewport_size.x - title_label.size.x) / 2, viewport_size.y / 2 - 150 * ui_scale)
	
	if menu_container:
		var container_width = 200 * ui_scale
		var container_height = (50 * 2 + 10) * ui_scale
		menu_container.position = Vector2((viewport_size.x - container_width) / 2, viewport_size.y / 2 - 50 * ui_scale)
	
	if play_button:
		play_button.custom_minimum_size = Vector2(200, 50) * ui_scale
		var font = play_button.get("custom_fonts/font")
		if font:
			font.size = int(16 * ui_scale)
	
	if quit_button:
		quit_button.custom_minimum_size = Vector2(200, 50) * ui_scale
		var font = quit_button.get("custom_fonts/font")
		if font:
			font.size = int(16 * ui_scale)
	
	if mute_button:
		mute_button.custom_minimum_size = Vector2(100, 40) * ui_scale
		var font = mute_button.get("custom_fonts/font")
		if font:
			font.size = int(16 * ui_scale)
		mute_button.position = Vector2(10 * ui_scale, 10 * ui_scale)
	
	if fullscreen_button:
		fullscreen_button.custom_minimum_size = Vector2(100, 40) * ui_scale
		var font = fullscreen_button.get("custom_fonts/font")
		if font:
			font.size = int(16 * ui_scale)
		var scaled_width = fullscreen_button.size.x
		fullscreen_button.position = Vector2(viewport_size.x - scaled_width - 10, 10)
	
	if website_button:
		website_button.custom_minimum_size = Vector2(100, 40) * ui_scale
		var font = website_button.get("custom_fonts/font")
		if font:
			font.size = int(16 * ui_scale)
		var scaled_width = website_button.size.x
		var scaled_height = website_button.size.y
		website_button.position = Vector2(viewport_size.x - scaled_width - 10, viewport_size.y - scaled_height - 10)
	
	if random_button:
		random_button.custom_minimum_size = Vector2(100, 40) * ui_scale
		var font = random_button.get("custom_fonts/font")
		if font:
			font.size = int(16 * ui_scale)
		var scaled_height = random_button.size.y
		random_button.position = Vector2(10, viewport_size.y - scaled_height - 10)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level_one.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_mute_toggled(button_pressed: bool):
	AudioServer.set_bus_mute(0, button_pressed)

func _on_fullscreen_pressed(_button_pressed):
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	adjust_ui_to_resolution()

func _on_website_pressed():
	OS.shell_open("https://arsenobetaine.itch.io/the_siderooms")
