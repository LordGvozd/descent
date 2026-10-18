extends Interactable

@onready var _animated_sprite: AnimatedSprite2D = $Sprite
@onready var _collider: CollisionShape2D = $"StaticBody2D/CollisionShape2D"

enum State { CLOSED, OPENING, OPENED, CLOSING }
var _state: State = State.CLOSED


func interact() -> void:
	if _state == State.CLOSED or _state == State.CLOSING:
		_state = State.OPENING
		_animated_sprite.play("opening")


func _process(_delta: float) -> void:
	if not _player_in and _state == State.OPENED:
		_state = State.CLOSING
		_animated_sprite.play("closing")


func _on_sprite_animation_finished() -> void:
	match _state:
		State.OPENING:
			_state = State.OPENED
			_animated_sprite.play("opened")
			_collider.disabled = true
		State.CLOSING:
			_state = State.CLOSED
			_animated_sprite.play("closed")
			_collider.disabled = false
