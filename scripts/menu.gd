extends Control

enum Target { PLAY, SETTINGS }

@export var buttons: Array[TextureButton]
@export var log_label: Label
@export var log_paragraph_delay: float

@export_group("Logs")
@export_file("*.txt") var play_button_log: String
@export_file("*.txt") var settings_button_log: String

@export_group("Scenes")
@export_file("*.tscn") var play_scene: String

@export_group("UI")
@export var main_ui: Control
@export var settings_panel: Control

@export_group("Transition")
@export var transition_type: String = "pixelate"
@export var transition_duration: float = 2.0

@onready var _timer: Timer = $Timer
@onready var _log_animation_player: AnimationPlayer = $LogAnimationPlayer
@onready var _block_displayed_audio_player: AudioStreamPlayer = $BlockDisplayedAudioStreamPlayer

var _blocks: Array[String] = []
var _block_index: int = 0
var _is_transition_started := false
var _is_log_playing := false
var _pending_target: int = -1


func _ready() -> void:
	_timer.wait_time = log_paragraph_delay
	_timer.one_shot = true
	if settings_panel:
		settings_panel.visible = false


func _set_buttons_enabled(enabled: bool) -> void:
	for button in buttons:
		if button:
			button.disabled = not enabled


func _finish_and_switch_scene() -> void:
	if _is_transition_started:
		return
	_is_transition_started = true

	var target := _pending_target
	_pending_target = -1

	match target:
		Target.PLAY:
			await Transition.cover(transition_type, transition_duration)
			get_tree().change_scene_to_file(play_scene)
			await Transition.reveal(transition_type, transition_duration)
		Target.SETTINGS:
			main_ui.visible = false
			settings_panel.visible = true
			_is_log_playing = false
			_set_buttons_enabled(true)

	_is_transition_started = false


func _parse_log_file(log_file_path: String) -> Array[String]:
	var blocks: Array[String] = []

	if log_file_path.is_empty():
		return blocks

	var file := FileAccess.open(log_file_path, FileAccess.READ)

	var log_content := file.get_as_text()
	file.close()

	var current_block := ""
	for line in log_content.split("\n"):
		if line.strip_edges().is_empty():
			if not current_block.is_empty():
				blocks.append(current_block)
				current_block = ""
		else:
			current_block = line if current_block.is_empty() else current_block + "\n" + line

	if not current_block.is_empty():
		blocks.append(current_block)

	return blocks


func _display_log(log_file_path: String, target: int) -> void:
	if _is_transition_started or _is_log_playing:
		return

	_is_log_playing = true
	_set_buttons_enabled(false)

	_timer.stop()
	_blocks = _parse_log_file(log_file_path)
	_block_index = 0
	_pending_target = target
	log_label.text = ""

	if _blocks.is_empty():
		_finish_and_switch_scene()
		return

	_show_next_block()


func _show_next_block() -> void:
	log_label.text = _blocks[_block_index]
	_block_index += 1

	_block_displayed_audio_player.play()
	_log_animation_player.play("typewriter")

	if _block_index < _blocks.size():
		_timer.start()
	else:
		_finish_and_switch_scene()


func _on_timer_timeout() -> void:
	_show_next_block()


func _on_play_button_pressed() -> void:
	_display_log(play_button_log, Target.PLAY)


func _on_settings_button_pressed() -> void:
	_display_log(settings_button_log, Target.SETTINGS)


func _on_back_button_pressed() -> void:
	main_ui.visible = true
	settings_panel.visible = false
