extends Area2D


enum Condition {
	ON_ENTER,
	ON_EXIT
}

@export var start_after: Task
@export var task: Task
@export var done_on: Condition
@export var new_task: Task


func _ready() -> void:
	if start_after:
		monitoring = false
		Bus.subscribe(TaskDoneEvent, func(e): if e == start_after: monitoring = true)
	


func _done():
	var done_event = TaskDoneEvent.new()
	done_event.task = task
	
	Bus.create_event(done_event)
	
	if new_task:
		var new_task_event = NewTaskEvent.new()
		new_task_event.task = new_task
		
		Bus.create_event(new_task_event)
		
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and done_on == Condition.ON_ENTER:
		_done()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and done_on == Condition.ON_EXIT:
		_done()
