@abstract
extends Area2D
class_name Interactable


var _player_in: bool = false

var _interactable_shader: ShaderMaterial = preload("res://shaders/interactable.tres")
var _ui_opened = false

@onready var _sprite: Sprite2D = $Icon


@abstract
func interact() -> void

func _init() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	Bus.subscribe(OpenUIEvent, func(e): _ui_opened = true)
	Bus.subscribe(CloseUIEvent, func(e): _ui_opened = false)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and _player_in and not _ui_opened:
		interact()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_sprite.material = _interactable_shader
		_player_in = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		_sprite.material = null
		_player_in = false
