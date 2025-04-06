extends Node

@export var normal_music: AudioStream
@export var chase_music: AudioStream
@export var fade_duration: float = 1.0
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var last_position: float = 0.0
var is_chasing: bool = false
var current_track: AudioStream = null
var is_transitioning: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if normal_music:
		audio_player.stream = normal_music
		audio_player.stream.loop = true
		current_track = normal_music
	if not audio_player.playing:
		audio_player.play()

func _process(_delta: float) -> void:
	if audio_player.playing:
		last_position = audio_player.get_playback_position()
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var should_be_chasing = false
	for enemy in enemies:
		if enemy.current_state in [enemy.State.CHASING, enemy.State.CHASING_PLAYER, enemy.State.CHASING_RUBY]:
			should_be_chasing = true
			break
	
	if should_be_chasing != is_chasing and not is_transitioning:
		is_chasing = should_be_chasing
		if is_chasing and chase_music and current_track != chase_music:
			switch_to_chase_music()
		elif not is_chasing and normal_music and current_track != normal_music:
			switch_to_normal_music()

func switch_to_chase_music() -> void:
	if chase_music and not is_transitioning:
		is_transitioning = true
		var tween = create_tween()
		tween.tween_property(audio_player, "volume_db", -80, fade_duration)
		tween.tween_callback(func():
			audio_player.stop()
			audio_player.stream = chase_music
			audio_player.stream.loop = true
			current_track = chase_music
			audio_player.volume_db = -80
			audio_player.play()
			var fade_in_tween = create_tween()
			fade_in_tween.tween_property(audio_player, "volume_db", 0, fade_duration)
			fade_in_tween.tween_callback(func():
				is_transitioning = false
			)
		)

func switch_to_normal_music() -> void:
	if normal_music and not is_transitioning:
		is_transitioning = true
		var tween = create_tween()
		tween.tween_property(audio_player, "volume_db", -80, fade_duration)
		tween.tween_callback(func():
			audio_player.stop()
			audio_player.stream = normal_music
			audio_player.stream.loop = true
			current_track = normal_music
			audio_player.volume_db = -80
			audio_player.play(last_position)
			var fade_in_tween = create_tween()
			fade_in_tween.tween_property(audio_player, "volume_db", 0, fade_duration)
			fade_in_tween.tween_callback(func():
				is_transitioning = false
			)
		)

func toggle_mute() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")))

func ensure_playing() -> void:
	if not audio_player.playing:
		audio_player.play(last_position)
