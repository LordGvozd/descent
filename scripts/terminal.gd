extends Interactable
class_name Terminal



@export var os: OperationalSysytem


@onready var code_edit = $CanvasLayer/UI/CodeEdit
@onready var output = $CanvasLayer/UI/Output

@onready var terminal_work_player = $AudioStreamPlayer2D

@export var start_sound: AudioStreamMP3
@export var work_sound: AudioStreamMP3
@export var stop_sound: AudioStreamMP3

@export var enter_sound: Array[AudioStreamMP3] = []
@export var btn_sound: Array[AudioStreamMP3] = []

var _is_open: bool = false

func _ready():
	print(os.env)
	# Создать пустую тему
	var invisible_theme = Theme.new()
	var empty_style = StyleBoxEmpty.new()
	
	# Установить пустой стиль для полосы прокрутки VScrollBar
	invisible_theme.set_stylebox("scroll", "VScrollBar", empty_style)

	code_edit.theme = invisible_theme
	output.theme = invisible_theme
	
	code_edit.text = os.entred_code
	
func interact() -> void:
	start()
	
func _input(event: InputEvent) -> void:
	super._input(event)
	if event is InputEventKey and event.pressed and _is_open:
		if event.keycode == KEY_ENTER:
			$ButtonSoundPlayer.stream = enter_sound.pick_random()
		elif event.keycode == KEY_ESCAPE:
			stop()
		else:
			$ButtonSoundPlayer.stream = btn_sound.pick_random()
		$ButtonSoundPlayer.play()

func start():
	_is_open = true
	$CanvasLayer.visible = true
	$Shader.visible = true
	
	Bus.create_event(OpenUIEvent.new())
	
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	
	terminal_work_player.stream = work_sound
	terminal_work_player.play()

func stop():
	$AnimationPlayer.play("fade_in")
	await $AnimationPlayer.animation_finished
	
	_is_open = false
	$CanvasLayer.visible = false
	$Shader.visible = false
	
	Bus.create_event(CloseUIEvent.new())

func _on_run_btn_pressed() -> void:
	var player_code: String = code_edit.text
	
	# В скрипте, где вы запускаете код игрока
	var lua := LuaState.new()
	lua.open_libraries() 
	
	var captured_output: Array[String] = []

	lua.globals["print"] = func(...args):
		var parts: Array[String] = []
		for arg in args:
			parts.append(str(arg))
		captured_output.append(" ".join(parts))
	
	for var_name in os.env.keys():
		print(var_name, os.env[var_name])
		lua.globals[var_name] = os.env[var_name]

	var result = lua.do_string(player_code)
	
	if result is LuaError:
		captured_output.append("[ERROR] " + result.message)


	for line in captured_output:
		output.text += ">>>   " +  line + "\n"
