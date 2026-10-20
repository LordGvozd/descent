extends AudioStreamPlayer2D


@export var step_sounds: Array[AudioStreamMP3]

var _can_play: bool = false
var _playing: bool = false

func _ready() -> void:
	Bus.subscribe(PlayerStartMove, start_play)
	Bus.subscribe(PlayerStopMove, stop_play)


func _play_step_sound() -> void:
	if not _playing:
		stream = step_sounds.pick_random()
		play()
		_playing = true
	


func start_play(e):
	_can_play = true
	_play_step_sound()
	
	
func stop_play(e):
	_can_play = false


func _on_finished() -> void:
	await get_tree().create_timer(.5).timeout
	if _can_play:
		_playing = false
		_play_step_sound()
		return
	_playing = false
