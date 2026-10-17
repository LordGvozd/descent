extends Interactable
class_name CassetePlayer

@export var cassets: Array[Cassete]
@export var buttons: Array[Button]

func _ready() -> void:
	$CanvasLayer/UI.visible = false
	Bus.subscribe(CassetePickEvent, add_cassete)
	for btn in buttons:
		btn.disabled = true
		btn.text = ""

func _update() -> void:
	for index in range(len(cassets)-1, -1, -1):
		var btn = buttons.get(index)
		
		if not btn:
			break
		
		btn.text = cassets[index].name
		btn.disabled = false
		
		btn.pressed.connect(func(): put_casset(cassets[index]))
		
func put_casset(casset: Cassete):
	$CanvasLayer/UI/VideoStreamPlayer.stream = casset.video
	$CanvasLayer/UI/VideoStreamPlayer.play()
		
func add_cassete(event: CassetePickEvent) -> void:
	var cassete = event.cassete
	
	if cassete not in cassets:
		cassets.append(cassete)

func interact() -> void:
	Bus.create_event(OpenUIEvent.new())
	$CanvasLayer/UI.visible = true
	_update()
	


func _on_on_off_button_button_up() -> void:
	Bus.create_event(CloseUIEvent.new())
	$CanvasLayer/UI/VideoStreamPlayer.stop()
	$CanvasLayer/UI.visible = false
	
