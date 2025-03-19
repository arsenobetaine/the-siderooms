class_name TransitionLevelCamera
extends Camera2D

@export var follow_speed: float = 15.0
@onready var player = get_node("/root/transition-level/entities/player")

func _ready():
	position = player.position

func _process(delta):
	var target_position = player.position
	var lerp_factor = 1.0 - exp(-follow_speed * delta)
	position = position.lerp(target_position, lerp_factor)
