extends Area2D

@export var scene: PackedScene


func _ready() -> void:
	$AnimationPlayer.play("fade_out")
	Bus.create_event(OpenUIEvent.new())

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$AnimationPlayer.play("fade_in")
		Bus.create_event(OpenUIEvent.new())
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name)
	if anim_name == "fade_in":
		get_tree().change_scene_to_packed(scene)
	if anim_name == "fade_out":
		Bus.create_event(CloseUIEvent.new())
	
