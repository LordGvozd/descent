extends SignalObject

@export var code: String

func off() -> void:
	$Door.open()
	
func on() -> void:
	$Door.close()
