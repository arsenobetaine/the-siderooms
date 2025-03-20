extends CanvasLayer

@onready var animation_player = $"animation-player"
@onready var color_rect = $"color-rect"

func _ready() -> void:
	if color_rect:
		color_rect.visible = false
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer = 1000

func start_transition(next_scene_path: String) -> void:
	if color_rect and animation_player:
		color_rect.visible = true
		color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		animation_player.play("fade-out")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(next_scene_path)
		await get_tree().create_timer(1.0).timeout
		color_rect.visible = false
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
