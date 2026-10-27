@abstract
extends Node2D
class_name SignalObject

@export var object_id: String
@export var object_name: String

func _init() -> void:
	if not object_id:
		print(object_id)
	Bus.subscribe(SignalEvent, _handle_event)

func _handle_event(event: SignalEvent) -> void:
	if event.object_id != object_id:
		return
		
	match event.signal_type:
		SignalEvent.SignalType.ON:
			on()
		SignalEvent.SignalType.OFF:
			off()

@abstract func on() -> void
@abstract func off() -> void
 
