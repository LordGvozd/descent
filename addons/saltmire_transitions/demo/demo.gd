extends Node2D
## Self-playing showcase: cycles through every built-in transition style,
## covering and revealing over a colorful scene. Click or press Space to
## trigger the next style immediately.

const STYLES := ["fade", "circle", "wipe_left", "wipe_right", "wipe_up", "wipe_down", "pixelate"]

@onready var label: Label = $UI/Style
@onready var hint: Label = $UI/Hint
var _i := 0


func _ready() -> void:
	_loop()


func _loop() -> void:
	while true:
		var style: String = STYLES[_i % STYLES.size()]
		label.text = style.to_upper().replace("_", " ")
		await get_tree().create_timer(0.7).timeout
		await Transition.cover(style, 0.5)
		_recolor()
		await get_tree().create_timer(0.15).timeout
		await Transition.reveal(style, 0.5)
		_i += 1


func _recolor() -> void:
	# swap the background palette so the reveal shows something new
	var h := randf()
	$BG.color = Color.from_hsv(h, 0.45, 0.16)
	$Shape.color = Color.from_hsv(fmod(h + 0.5, 1.0), 0.7, 0.95)
	$Shape.position = Vector2(randf_range(400, 880), randf_range(260, 500))


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) \
			or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		if not Transition.is_busy():
			_i += 1  # skip forward; the loop picks it up on next iteration
