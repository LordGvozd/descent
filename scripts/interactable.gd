@abstract
extends Area2D
class_name Interactable

var _player_in: bool = false

@abstract
func interact() -> void

func _init() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and _player_in:
		interact()

func _on_body_entered(body: Node2D) -> void:
	print("Somesd")
	if body.is_in_group("Player"):
		_player_in = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in = false
