extends Node

var game_state: String = "none"

func set_game_state(state: String) -> void:
	game_state = state

func get_game_state() -> String:
	return game_state

func clear_game_state() -> void:
	game_state = "none"
