extends Node2D
class_name Teleport

@export var point: Marker2D
@export var loop_iteration_objects: Array[Node2D]
@export var marker_sprite: Sprite2D
@export var marker_sprite_variants: Array[Texture2D]
@export var percent_visible = 30

var _dublicats: Array[Node2D]

func _ready() -> void:
	var visible_target_count = roundf(len(loop_iteration_objects) * 0.01 * percent_visible)
	var visible_coint = 0
	
	for obj in loop_iteration_objects:
		obj.visible = false

	var co = 0
	while visible_coint < visible_target_count:
		if co >= len(loop_iteration_objects) + 30:
			break
		co += 1
		
		var random_obj = loop_iteration_objects.pick_random()
		if _is_on_screen(random_obj):
			continue
		random_obj.visible = true
		visible_coint += 1

func _is_on_screen(sprite: Sprite2D) -> bool:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return false
	
	var screen_center = camera.get_screen_center_position()
	var half_size = get_viewport_rect().size / (2.0 * camera.zoom)
	var screen_rect = Rect2(screen_center - half_size, half_size * 2.0)
	
	return screen_rect.has_point(sprite.global_position)

func _on_area_2d_body_entered(body: Node2D) -> void:

				
	
	var camera = get_viewport().get_camera_2d()
	
	if body.is_in_group("Player"):
		
		for d in _dublicats:
			d.queue_free()
		
		_dublicats.clear()
		for obj in loop_iteration_objects:
			if obj.visible:
				if _is_on_screen(obj):
					var c = obj.duplicate()
					add_child(c)
					
					c.global_position = obj.global_position - global_position + point.global_position
					

					_dublicats.append(c)
					
		for obj in loop_iteration_objects:
			obj.visible = false
		
		body.global_position = point.global_position
		
		camera.force_update_scroll()
		camera.reset_smoothing()
		camera.reset_smoothing()
		
		# В момент телепорта
		for i in range(5):
			camera.offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			await get_tree().create_timer(0.05).timeout
		camera.offset = Vector2.ZERO
		
		
		var visible_target_count = roundf(len(loop_iteration_objects) * 0.01 * percent_visible)
		var visible_coint = 0
		
		var co = 0
		while visible_coint < visible_target_count:
			if co >= len(loop_iteration_objects) + 30:
				break
			co += 1
			
			var random_obj = loop_iteration_objects.pick_random()
			if _is_on_screen(random_obj) or random_obj.visible:
				continue
			random_obj.visible = true
			print(visible_coint, " ", visible_target_count)
			visible_coint += 1
			
	
			
			
			
		
		
