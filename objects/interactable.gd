@abstract
extends Area2D
class_name Interactable

var _player_in: bool

@abstract
func interact() -> void

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		interact()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_player_in = false
