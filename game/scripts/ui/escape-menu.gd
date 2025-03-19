extends CanvasLayer

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_WHEN_PAUSED)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_parent().toggle_menu()
		get_viewport().set_input_as_handled()
