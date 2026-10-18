extends AnimatedSprite2D

@export var animation_speed_scale: float = 1


func _ready() -> void:
	speed_scale = animation_speed_scale
	flip_h = false


func _process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if input_dir.x > 0:
		play("walk_front")
		flip_h = false
	elif input_dir.x < 0:
		play("walk_front")
		flip_h = true
	elif input_dir.y > 0:
		play("walk_down")
	elif input_dir.y < 0:
		play("walk_up")
