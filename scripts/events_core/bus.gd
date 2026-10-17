extends Node

var subscribers = {}


func subscribe(event, function: Callable) -> void:
	var event_type = event.get_global_name()

	
	if subscribers.get(event_type, null) == null:
		subscribers[event_type] = []
		
	subscribers[event_type].append(function)


func create_event(event: IEvent) -> void:
	var event_type = event.get_script().get_global_name()
	
	var event_subscribers = subscribers.get(event_type, [])
	for index in range(len(event_subscribers)):
		if event_subscribers[index] == null:
			subscribers[event].remove_at(index)
			
		event_subscribers[index].call_deferred(event)
