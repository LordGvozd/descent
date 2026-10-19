extends Node2D


func _ready() -> void:
	Bus.subscribe(OpenUIEvent, func(e): $CanvasLayer.visible = false)
	Bus.subscribe(CloseUIEvent, func(e): $CanvasLayer.visible = true)
	
