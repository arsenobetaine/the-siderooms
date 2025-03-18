extends Node2D

func _ready() -> void:
	_handle_fade_in()

func _handle_fade_in() -> void:
	var transition_scene = get_node_or_null("/root/fade-transition")
	if transition_scene:
		var animation_player = transition_scene.get_node("animation-player")
		if animation_player:
			if animation_player.has_animation("fade-in"):
				animation_player.play("fade-in")
				await animation_player.animation_finished
			transition_scene.queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
