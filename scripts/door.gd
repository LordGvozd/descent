extends Interactable
class_name Door

@export var code: String

var _opened: bool = false


func _ready() -> void:
	code = $"..".code
	$AnimatedSprite2D.play("idle")
	
	if code:
		Bus.subscribe(PinCodeOKEvent, func(e): if e.code == code: open())
		
	if not code:
		$Sprite.visible = false

func open() -> void:
	$AnimatedSprite2D.play("open")
	$AudioStreamPlayer2D.play()
	$Sprite.visible = false
	_opened = true
	
	await get_tree().create_timer(.3).timeout
	$StaticBody2D/CollisionShape2D.disabled = true
	
func close() -> void:
	$AnimatedSprite2D.play("close")
	$AudioStreamPlayer2D.play()
	$Sprite.visible = true
	_opened = false
	
	await get_tree().create_timer(.3).timeout
	$StaticBody2D/CollisionShape2D.disabled = false
	
func interact() -> void:
	if not _opened:
		if code:
			var event = OpenPinCodeEvent.new()
			event.code = code
			Bus.create_event(event)
