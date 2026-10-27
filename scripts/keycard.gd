extends Interactable
class_name Keycard

@export var singal_code: String = "1337"

func interact() -> void:
	var e = SignalEvent.new()
	e.object_id = singal_code
	Bus.create_event(e)
	
	queue_free()
