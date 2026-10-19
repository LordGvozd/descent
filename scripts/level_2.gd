extends Node2D

@export var start_tasks: Array[Task] = []

func _ready() -> void:
	for task in start_tasks:
		var e = NewTaskEvent.new()
		e.task = task
		Bus.create_event(e)
