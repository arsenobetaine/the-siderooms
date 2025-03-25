extends AudioStreamPlayer

var last_position: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if stream != null:
		stream.loop = true
	if not playing:
		play()

func toggle_mute() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))

func ensure_playing() -> void:
	if not playing:
		play(last_position)

func _process(_delta: float) -> void:
	if playing:
		last_position = get_playback_position()
