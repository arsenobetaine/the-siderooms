extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level-one.tscn")

func _on_quit_button_pressed() -> void:
	if OS.get_name() == "HTML5":
		JavaScriptBridge.eval("window.close();")
	else:
		get_tree().quit()

func _on_fullscreen_button_pressed() -> void:
	if OS.get_name() == "HTML5":
		if JavaScriptBridge.eval("document.fullscreenElement != null", true):
			JavaScriptBridge.eval("document.exitFullscreen();")
		else:
			JavaScriptBridge.eval("document.getElementById('canvas').requestFullscreen();")
	else:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_website_button_pressed() -> void:
	OS.shell_open("https://arsenobetaine.itch.io/the-siderooms")
