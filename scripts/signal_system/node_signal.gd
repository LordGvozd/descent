extends SignalObject
class_name VisibleSignalObj

func _ready() -> void:
	if not object_id:
		object_id = str(randi_range(10, 10000))

func on() -> void:
	visible = true
	
func off() -> void:
	visible = false
