extends Node2D



@export var number_buttons: Array[TextureButton]
@onready var label: Label = $CanvasLayer/UI/Label
@export var delete_button: TextureButton
@export var ok_button: TextureButton

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
	$CanvasLayer/UI.visible = true
	
func close_pincode():
	$CanvasLayer/UI.visible = false
	Bus.create_event(CloseUIEvent.new())
		
func type_number(number: int):
	label.text += str(number)
	_entered_numbers.append(number)
	
	
func delete_last():
	# ToDo: Add sound
	if len(_entered_numbers) == 0:
		return
		
	label.text = label.text.substr(0, label.text.length() - 1)
	_entered_numbers.remove_at(-1)
	
func check_code():
	
	if target_code == _entered_numbers:
		var event = PinCodeOKEvent.new()
		event.code = code
		Bus.create_event(event)
		close_pincode()
		return

	if _used_attempts >= max_attempts:
		var event = PinCodeERREvent.new()
		event.code = code
		Bus.create_event(event)
		close_pincode()
		return
	
	_used_attempts += 1
	# ToDo: Add sound incorrect
	
	
	
