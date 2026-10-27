extends Interactable
class_name Terminal



@export var os: OperationalSysytem
@export var room: Room

@onready var code_edit = $CanvasLayer/UI/CodeEdit
@onready var output = $CanvasLayer/UI/Output

@onready var terminal_work_player = $AudioStreamPlayer2D

@export var start_sound: AudioStreamMP3
@export var work_sound: AudioStreamMP3
@export var stop_sound: AudioStreamMP3
@export var max_lines = 30

@export var enter_sound: Array[AudioStreamMP3] = []
@export var btn_sound: Array[AudioStreamMP3] = []


var _is_open: bool = false



func _ready():
	# Создать пустую тему
	var invisible_theme = Theme.new()
	var empty_style = StyleBoxEmpty.new()
	
	# Установить пустой стиль для полосы прокрутки VScrollBar
	invisible_theme.set_stylebox("scroll", "VScrollBar", empty_style)

	code_edit.theme = invisible_theme
	output.theme = invisible_theme
	
	code_edit.text = os.entred_code
	
	var keyword_color = Color("#A36F5C")
	var lua_keywords = [
		"and", "break", "do", "else", "elseif",
		"end", "false", "for", "function", "goto",
		"if", "in", "local", "nil", "not",
		"or", "repeat", "return", "then", "true",
		"until", "while"
	]
	
	for kw in lua_keywords:
		code_edit.syntax_highlighter.keyword_colors[kw] = keyword_color
	
	
	
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

func _send_signal(name: String) -> void:
	pass

func _on_run_btn_pressed() -> void:
	var player_code: String = code_edit.text
	
	# В скрипте, где вы запускаете код игрока
	var lua := LuaState.new()
	lua.open_libraries() 
	lua.do_string("""
    __stop_requested = false
    __instruction_count = 0
    __instruction_limit = 10000  
    __check_interval = 500      
    
    debug.sethook(function()
        __instruction_count = __instruction_count + __check_interval
        if __stop_requested or __instruction_count > __instruction_limit then
			error("Script stopped: instruction limit exceeded", 0)
        end
	end, "", __check_interval)
""")
	
	var captured_output: Array[String] = []

	lua.globals["print"] = func(...args):
		var parts: Array[String] = []
		for arg in args:
			parts.append(str(arg))
		captured_output.append(" ".join(parts))
		
	lua.globals["send_signal"] = func(sig_name, id): 
		if not id:
			captured_output.append("[ERROR] You should provide id of object, that recived signal!")
			return
		
		var e = SignalEvent.new()
		e.object_id = str(id)
		
		match sig_name:
			"on":
				e.signal_type = SignalEvent.SignalType.ON
			"off":
				e.signal_type = SignalEvent.SignalType.OFF
			_:
				captured_output.append("[ERROR] Incorret signal name!")
				return
			
		Bus.create_event(e)
		captured_output.append("signal sended")
		
	lua.globals["room"] = room.as_dict()
			
	for var_name in os.env.keys():
		print(var_name, os.env[var_name])
		lua.globals[var_name] = os.env[var_name]

	var result = lua.do_string(player_code)
	
	if result is LuaError:
		captured_output.append("[ERROR] " + result.message)

	var text_to_print = ""
	
	for line in captured_output:
		text_to_print += ">>>   " +  line + "\n"
		
	_print_smooth(text_to_print)
	
func _print_smooth(text: String) -> void:
	if not text:
		return
	var duration = .7
	var delay = duration / len(text) 
	for c in text:
		output.text += c
		await get_tree().create_timer(delay).timeout
	
	var lines = output.text.split("\n")
	if lines.size() > max_lines:
		output.text = "\n".join(lines.slice(lines.size() - max_lines))
	
	
