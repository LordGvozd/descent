extends Node2D

@export var labels: Array[Label]
@export var new_message_sound: AudioStreamMP3

var tasks: Array[Task] = []
var _is_open: bool = false


func _ready() -> void:
	Bus.subscribe(NewTaskEvent, func(e): set_task(e.task))

func _update() -> void:
	for index in range(len(labels)):
		if index + 1 > len(tasks):
			labels[index].text = ""
			continue
			
		var task = tasks.get(index)
		
		labels[index].text = task.text
		

func set_task(task: Task) -> void:
	tasks.append(task)
	_update()
	$AudioStreamPlayer2D.stream = new_message_sound
	$AudioStreamPlayer2D.play()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("open_phone"):
		if _is_open:
			$CanvasLayer/Control.visible = false
			_is_open = false
			Bus.create_event(CloseUIEvent.new())
		else:
			$CanvasLayer/Control.visible = true
			_is_open = true
			Bus.create_event(OpenUIEvent.new())
			_update()
