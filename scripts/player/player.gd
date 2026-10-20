extends Node2D


func _ready() -> void:
	Bus.subscribe(OpenUIEvent, func(e): if e.turn_off_shader:  $CanvasLayer.visible = false)
	Bus.subscribe(CloseUIEvent, func(e): $CanvasLayer.visible = true)
	
