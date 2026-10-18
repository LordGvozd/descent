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
		var textures = cassets[index].textures
		
		_set_button_texture(btn, "normal", textures.normal)
		_set_button_texture(btn, "pressed", textures.pressed)
		_set_button_texture(btn, "hover", textures.hover)
		_set_button_texture(btn, "disabled", textures.disabled)
		
		btn.disabled = false
		
		btn.pressed.connect(func(): put_casset(cassets[index]))
		
func _set_button_texture(button, state: String, texture: Texture2D):
	# 1. Берём текущий стиль кнопки (чтобы не потерять отступы из редактора)
	var style = button.get_theme_stylebox(state).duplicate()
	
	# 2. Если это StyleBoxTexture — меняем картинку
	if style is StyleBoxTexture:
		style.texture = texture
	
	button.add_theme_stylebox_override(state, style)

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
	
