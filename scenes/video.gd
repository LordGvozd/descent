extends Control


@export var scene: PackedScene

func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_packed(scene)
