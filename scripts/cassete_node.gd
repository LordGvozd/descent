extends Interactable
class_name CasseteNode

@export var cassete: Cassete

func interact() -> void:
	var event = CassetePickEvent.new()
	
	event.cassete = cassete
	
	Bus.create_event(event)
	queue_free()
