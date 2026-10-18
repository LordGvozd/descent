extends CharacterBody2D

@export var speed = 10

var _prev_dir: Vector2 = Vector2.ZERO
var _can_move: bool = true

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	Bus.subscribe(OpenUIEvent, func(event): _can_move = false)
	Bus.subscribe(CloseUIEvent, func(event): _can_move = true)


func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if not _can_move:
		input_dir = Vector2.ZERO

	if _prev_dir == Vector2.ZERO and input_dir != Vector2.ZERO:
		Bus.create_event(PlayerStartMove.new())

	if _prev_dir != Vector2.ZERO and input_dir == Vector2.ZERO:
		Bus.create_event(PlayerStopMove.new())

	_prev_dir = input_dir

	velocity = input_dir * speed

	move_and_slide()
