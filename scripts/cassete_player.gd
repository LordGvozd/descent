extends Interactable
class_name CassetePlayer

@export var cassets: Array[Cassete]
@export var buttons: Array[Button]

@export var default_video: VideoStream

@export var casset_put_sound: AudioStreamMP3
@export var casset_input_sound: AudioStreamMP3
@export var off_on_sound: AudioStreamMP3

@export var mini_buttons_sounds: Array[AudioStreamMP3]

var _playing_casset = false

func _ready() -> void:
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
		
		btn.pressed.connect(func(): put_casset(index))
		
func _set_button_texture(button, state: String, texture: Texture2D):
	# 1. Берём текущий стиль кнопки (чтобы не потерять отступы из редактора)
	var style = button.get_theme_stylebox(state).duplicate()
	
	# 2. Если это StyleBoxTexture — меняем картинку
	if style is StyleBoxTexture:
		style.texture = texture
	
	button.add_theme_stylebox_override(state, style)

func _input_casset():
	if _playing_casset:
		$CassetSoundsPlayer.stream = casset_input_sound
		$CassetSoundsPlayer.play()
		
		await $CassetSoundsPlayer.finished
		await get_tree().create_timer(.3).timeout
		
		_update()
		_playing_casset = false
		
		$CanvasLayer/UI/VideoStreamPlayer.paused = false
		$CanvasLayer/UI/mouth_open.visible = true
		$CanvasLayer/UI/VideoStreamPlayer.stream = default_video
		$CanvasLayer/UI/VideoStreamPlayer.play()
		

func put_casset(index: int):
	await _input_casset()

					
	$CanvasLayer/UI/mouth_open.visible = true
	$CassetSoundsPlayer.stream = casset_put_sound
	$CassetSoundsPlayer.play()
	
	await $CassetSoundsPlayer.finished
	
	await get_tree().create_timer(.3).timeout
	
	$CanvasLayer/UI/mouth_open.visible = false

	var casset = cassets[index]
	var btn = buttons[index]
	
	
		
	btn.text = ""
	btn.disabled = true
	
	$CanvasLayer/UI/VideoStreamPlayer.stream = casset.video
	$CanvasLayer/UI/VideoStreamPlayer.play()
	
	btn.disabled = true
	_playing_casset = true
	
	var cassete_played_event = CassetePlayedEvent.new()
	cassete_played_event.cassete = casset
	Bus.create_event(cassete_played_event)
		
func add_cassete(event: CassetePickEvent) -> void:
	var cassete = event.cassete
	
	if cassete not in cassets:
		cassets.append(cassete)

func interact() -> void:
	Bus.create_event(OpenUIEvent.new())
	
	$Shader.visible = true
	$CanvasLayer/UI/VideoStreamPlayer.stream = null
	$CanvasLayer/UI.visible = true
	$CanvasLayer/UI/Block.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_playing_casset = false
	$CanvasLayer/UI/VideoStreamPlayer.paused = false
	_update()
	
	$CassetSoundsPlayer.stream = off_on_sound
	$CassetSoundsPlayer.play()
	await $CassetSoundsPlayer.finished
	await get_tree().create_timer(.5).timeout

	
	$CanvasLayer/UI/VideoStreamPlayer.stream = default_video
	$CanvasLayer/UI/VideoStreamPlayer.play()
	


func _on_on_off_button_button_up() -> void:
	$CanvasLayer/UI/Block.mouse_filter = Control.MOUSE_FILTER_STOP
	$CassetSoundsPlayer.stream = off_on_sound
	$CassetSoundsPlayer.play()
	await $CassetSoundsPlayer.finished
	_input_casset()
	if $CassetSoundsPlayer.playing:
		await $CassetSoundsPlayer.finished
	await get_tree().create_timer(1.5).timeout
	$CanvasLayer/UI/mouth_open.visible = false
	
	Bus.create_event(CloseUIEvent.new())
	$CanvasLayer/UI/VideoStreamPlayer.stop()
	$CanvasLayer/UI/VideoStreamPlayer.stream = null
	
	
	await get_tree().create_timer(.8).timeout

	$CanvasLayer/UI.visible = false
	$Shader.visible = false

	
func _play_mini_btn_sound() -> void:
	$MiniButtonsPlayer.stream = mini_buttons_sounds.pick_random()
	$MiniButtonsPlayer.play()

func _on_minus_button_pressed() -> void:
	_play_mini_btn_sound()
	$CanvasLayer/UI/VideoStreamPlayer.volume_db -= 5


func _on_pause_button_pressed() -> void:
	_play_mini_btn_sound()
	if _playing_casset:
		$CanvasLayer/UI/VideoStreamPlayer.paused = true


func _on_play_button_pressed() -> void:
	_play_mini_btn_sound()
	if _playing_casset:
		$CanvasLayer/UI/VideoStreamPlayer.paused = false
	

func _on_plus_button_pressed() -> void:
	_play_mini_btn_sound()
	$CanvasLayer/UI/VideoStreamPlayer.volume_db += 5
