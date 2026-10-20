extends Interactable
class_name Door

@export var code: String
@export var door_id: String

var _opened: bool = false


func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	
	if door_id:
		Bus.subscribe(SignalOpenEvent, func(e): if e.id == door_id: open())
	
	if code:
		Bus.subscribe(PinCodeOKEvent, func(e): if e.code == code: open())
		
	if not (code or door_id):
		$Sprite.visible = false

func open() -> void:
	$AnimatedSprite2D.play("open")
	$AudioStreamPlayer2D.play()
	$Sprite.visible = false
	_opened = true
	
	await get_tree().create_timer(.3).timeout
	$StaticBody2D/CollisionShape2D.disabled = true
	
func interact() -> void:
	if not _opened:
		if code:
			var event = OpenPinCodeEvent.new()
			event.code = code
			Bus.create_event(event)
