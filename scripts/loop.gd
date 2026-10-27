extends Node2D
class_name Teleport

@export var point: Marker2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	var camera = get_viewport().get_camera_2d()
	
	if body.is_in_group("Player"):
		
		body.global_position = point.position
		
		camera.force_update_scroll()
		camera.reset_smoothing()
		camera.reset_smoothing()
		
		# В момент телепорта
		for i in range(5):
			camera.offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			await get_tree().create_timer(0.05).timeout
		camera.offset = Vector2.ZERO
