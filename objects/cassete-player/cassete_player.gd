extends Interactable
class_name CassetePlayer

@export var cassets: Array[Cassete]
@export var buttons: Array[Button]

func _ready() -> void:
	Bus.subscribe(CassetePickEvent, add_cassete)

func _update() -> void:
	pass

func add_cassete(event: CassetePickEvent) -> void:
	var cassete = event.cassete
	
	if cassete not in cassets:
		cassets.append(cassete)

func interact() -> void:
	$UI.visible = true
	
