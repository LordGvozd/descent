extends CharacterBody2D
class_name Huskath

@onready var agent: NavigationAgent2D = $NavigationAgent2D
@export var speed: int = 40

var _follow_player: bool = false

func _ready() -> void:
	start_follow_player()

func start_follow_player() -> void:
	_follow_player = true
	$Sprite.play("run")

func stop_follow_player() -> void:
	_follow_player = false
	$Sprite.play("run")

func _process(_delta: float) -> void:
	if _follow_player:
		var player = get_tree().get_first_node_in_group("Player")
		
		agent.target_position = player.global_position
		var next_pos = agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * speed
		move_and_slide()
		
		
