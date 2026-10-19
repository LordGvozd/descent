extends Interactable

@onready var _animated_sprite: AnimatedSprite2D = $Sprite
@onready var _collider: CollisionShape2D = $"StaticBody2D/CollisionShape2D"

@export var pincode: String = "1337"
@export var opened: bool = false

enum State { CLOSED, OPENING, OPENED, CLOSING }
var _state: State = State.CLOSED
var _pin_code_entered: bool = false


func _ready() -> void:
	Bus.subscribe(PinCodeOKEvent, func(e): if e.code == pincode: _pin_code_entered = true)
	Bus.subscribe(SignalOpenEvent, func(e): if e.id == pincode: _pin_code_entered = true)

func interact() -> void:
	print("burmulda")
	if not _pin_code_entered and not opened:
		var pincode_event = OpenPinCodeEvent.new()
		pincode_event.code = pincode
		Bus.create_event(pincode_event)
		return
	
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
