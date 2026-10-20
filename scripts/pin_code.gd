extends Node2D



@export var number_buttons: Array[TextureButton]
@onready var label: Label = $CanvasLayer/UI/Label
@export var delete_button: TextureButton
@export var ok_button: TextureButton

@export var succes_color: Color
@export var error_color: Color

@export var button_sounds: Array[AudioStreamMP3]
@export var error_sound: AudioStreamMP3
@export var success_sound: AudioStreamMP3

var _entered_numbers: Array[int] = []
var target_code: Array[int] = [3, 4, 5]
var max_attempts: int = 100
var code: String
var _used_attempts: int = 0

func _ready() -> void:
	Bus.subscribe(OpenPinCodeEvent, open_pincode)
	
	for index in range(len(number_buttons)):
		number_buttons[index].button_up.connect(func(): type_number(index))
		
	delete_button.button_up.connect(func(): delete_last())
	ok_button.button_up.connect(func(): check_code())
		
		
func open_pincode(event: OpenPinCodeEvent):
	Bus.create_event(OpenUIEvent.new())
	_used_attempts = 0
	max_attempts = event.attempts
	code = event.code
	_entered_numbers = []
	$CanvasLayer/UI/Label.text = ""
	target_code = []
	for char in code:
		target_code.append(int(char))
		
	$CanvasLayer/UI/Label.add_theme_color_override("font_color", Color.WHITE)
	$CanvasLayer/UI.visible = true
	
func close_pincode():
	_entered_numbers = []
	$CanvasLayer/UI.visible = false
	Bus.create_event(CloseUIEvent.new())
		
func type_number(number: int):
	_play_sound()
	await get_tree().create_timer(.2).timeout

	label.text += str(number)
	_entered_numbers.append(number)
	
	
func _play_sound() -> void:
	var sound = button_sounds.pick_random()
	$Player.stream = sound
	$Player.play()
	
func delete_last():
	_play_sound()
	await get_tree().create_timer(.2).timeout
	# ToDo: Add sound
	if len(_entered_numbers) == 0:
		return
		
	label.text = label.text.substr(0, label.text.length() - 1)
	_entered_numbers.remove_at(-1)
	
func check_code():
	_play_sound()
	await get_tree().create_timer(.2).timeout
	print(target_code, _entered_numbers)
	if target_code == _entered_numbers:
		$CanvasLayer/UI/Label.add_theme_color_override("font_color", succes_color)
		$ErrorPlayer.stream = success_sound
		$ErrorPlayer.play()
		await get_tree().create_timer(.6).timeout
		var event = PinCodeOKEvent.new()
		event.code = code
		Bus.create_event(event)
		target_code = []
		_entered_numbers = []
		close_pincode()
		return
	
	
	await get_tree().create_timer(.1).timeout
	$CanvasLayer/UI/Label.add_theme_color_override("font_color", error_color)

	$ErrorPlayer.stream = error_sound
	$ErrorPlayer.play()
	await get_tree().create_timer(.9).timeout
	$CanvasLayer/UI/Label.add_theme_color_override("font_color", Color.WHITE)

	
	if _used_attempts >= max_attempts:
		var event = PinCodeERREvent.new()
		event.code = code
		Bus.create_event(event)
		close_pincode()
		return
	
	_used_attempts += 1
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Bus.create_event(CloseUIEvent.new())
		$CanvasLayer/UI.visible = false
		
		
