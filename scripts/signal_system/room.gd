extends Node2D
class_name Room

@export var room_name: String
@export var objects: Array[SignalObject]

func list_objects() -> Array:
	var list = []
	for obj in objects:
		list.append({obj.object_id: obj.object_name})
		
	return list

func as_dict() -> Dictionary:
	var room_dict = {}
	
	room_dict["objects"] = list_objects()
	room_dict["name"] = room_name
	
	return room_dict
