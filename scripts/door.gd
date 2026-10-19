extends Area2D
class_name Door

@export var code: String
@export var door_id: String

var _opened: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	
	if door_id:
		Bus.subscribe(SignalOpenEvent, func(e): if e.id == door_id: _open())
	
	if code:
		Bus.subscribe(PinCodeOKEvent, func(e): if e.code == code: _open())

func _open() -> void:
	$AnimatedSprite2D.play("open")
	$StaticBody2D/CollisionShape2D.disabled = true
	_opened = true
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not _opened:
			if code:
				var event = OpenPinCodeEvent.new()
				event.code = code
				Bus.create_event(event)


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
