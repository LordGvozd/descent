extends Node2D

@export var task: Task
@export var target_event: IEvent
@export var new_task: Task

func _ready() -> void:
	Bus.subscribe(target_event.get_script(),func(e): _compare(e))

func get_comparable_properties(res: Resource) -> Dictionary:
	var result = {}
	for prop in res.get_property_list():
		# Пропускаем служебные свойства
		if prop.name.begins_with("metadata/"):
			continue
		if prop.name in ["script", "resource_name", "resource_local_to_scene", "resource_path"]:
			continue
		# Берём только экспортируемые свойства (или все, кроме встроенных)
		if prop.usage & PROPERTY_USAGE_STORAGE:
			result[prop.name] = res.get(prop.name)
	return result

func _compare(e):
	if get_comparable_properties(e) == get_comparable_properties(target_event):
		_done()
	

func _done():
	var done_event = TaskDoneEvent.new()
	done_event.task = task
	
	Bus.create_event(done_event)
	
	if new_task:
		var new_task_event = NewTaskEvent.new()
		new_task_event.task = new_task
		
		Bus.create_event(new_task_event)
		
	queue_free()
	
