extends AnimatedSprite2D

@export var animation_speed_scale: float = 1

var _last_dir: Vector2 = Vector2.ZERO
var _can_move: bool = true

func _ready() -> void:
	speed_scale = animation_speed_scale
	flip_h = false
	
	Bus.subscribe(OpenUIEvent, func(e): _can_move = false)
	Bus.subscribe(CloseUIEvent, func(e): _can_move = true)

func _process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if not _can_move:
		if _last_dir.x > 0:
			play("idle_front")
			flip_h = false
		elif _last_dir.x < 0:
			play("idle_front")
			flip_h = true
		elif _last_dir.y > 0:
			play("idle_down")
		elif _last_dir.y < 0:
			play("idle_up")
		return
		
	# Idle.
	if input_dir == Vector2.ZERO:
		if _last_dir.x > 0:
			play("idle_front")
			flip_h = false
		elif _last_dir.x < 0:
			play("idle_front")
			flip_h = true
		elif _last_dir.y > 0:
			play("idle_down")
		elif _last_dir.y < 0:
			play("idle_up")
	
	# Walk.
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
	




	_last_dir = input_dir
