extends PointLight2D
class_name Lamp

func _input(event: InputEvent) -> void:
	if is_instance_of(event, InputEventMouseMotion):
		look_at(get_global_mouse_position())
