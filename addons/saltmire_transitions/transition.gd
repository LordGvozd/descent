extends CanvasLayer
## Saltmire Transitions — a tiny, free scene-transition manager for Godot 4.
##
## Drop-in autoload. One line to change scenes with a polished transition:
##
##     Transition.to("res://levels/level_2.tscn", "fade")
##
## Or just cover / reveal the screen without changing scenes:
##
##     await Transition.cover("circle")
##     # ... do work while the screen is hidden ...
##     await Transition.reveal("circle")
##
## Built-in styles: "fade", "circle", "wipe_left", "wipe_right",
## "wipe_up", "wipe_down", "pixelate". Register your own with add_style().
##
## MIT licensed. Part of the Saltmire game-feel family.

signal covered            ## Emitted the moment the screen is fully hidden.
signal revealed           ## Emitted the moment the screen is fully shown.
signal scene_changed(path) ## Emitted after the new scene is swapped in.

const SHADER_DIR := "res://addons/saltmire_transitions/shaders/"

## Default duration (seconds) for one half of a transition.
@export var duration: float = 0.4
## Default color used by shape-based styles (fade/circle/wipe/pixelate).
@export var color: Color = Color.BLACK

var _rect: ColorRect
var _mat: ShaderMaterial
var _busy := false
var _styles := {}

# Maps a style name -> {shader: String path or "", invert_on_reveal: bool}
const BUILTIN := {
	"fade":       {"shader": "",                 "flip": false},
	"circle":     {"shader": "circle.gdshader",  "flip": true},
	"wipe_left":  {"shader": "wipe.gdshader",    "flip": true, "dir": Vector2(-1, 0)},
	"wipe_right": {"shader": "wipe.gdshader",    "flip": true, "dir": Vector2(1, 0)},
	"wipe_up":    {"shader": "wipe.gdshader",    "flip": true, "dir": Vector2(0, -1)},
	"wipe_down":  {"shader": "wipe.gdshader",    "flip": true, "dir": Vector2(0, 1)},
	"pixelate":   {"shader": "pixelate.gdshader","flip": true},
}


func _ready() -> void:
	layer = 128  # draw above everything
	_rect = ColorRect.new()
	_rect.color = color
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.modulate.a = 0.0
	add_child(_rect)
	_mat = ShaderMaterial.new()
	_rect.material = _mat
	for name in BUILTIN:
		_styles[name] = BUILTIN[name].duplicate()
	get_viewport().size_changed.connect(_fit)
	_fit()


func _fit() -> void:
	if _rect:
		_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## True while a transition is in progress. Calls are ignored while busy.
func is_busy() -> bool:
	return _busy


## Register (or override) a custom style backed by your own shader.
## `opts` may include {"shader": "res://path.gdshader", "flip": bool}.
func add_style(name: String, opts: Dictionary) -> void:
	_styles[name] = opts


## Cover the screen with the given style. Awaitable.
func cover(style: String = "fade", dur: float = -1.0, col: Variant = null) -> void:
	await _run(style, true, dur, col)
	covered.emit()


## Reveal the screen (undo a cover) with the given style. Awaitable.
func reveal(style: String = "fade", dur: float = -1.0, col: Variant = null) -> void:
	await _run(style, false, dur, col)
	revealed.emit()


## Cover -> change_scene -> reveal, all in one awaitable call.
func to(scene_path: String, style: String = "fade", dur: float = -1.0, col: Variant = null) -> void:
	if _busy:
		return
	await cover(style, dur, col)
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("Transition.to(): could not load '%s' (error %d)" % [scene_path, err])
	scene_changed.emit(scene_path)
	# let the new scene enter the tree before revealing
	await get_tree().process_frame
	await reveal(style, dur, col)


func _run(style: String, covering: bool, dur: float, col: Variant) -> void:
	if _busy:
		# queue-lite: wait for the current one to finish, then proceed
		while _busy:
			await get_tree().process_frame
	_busy = true
	var s: Dictionary = _styles.get(style, _styles["fade"])
	var d: float = dur if dur > 0.0 else duration
	var use_col: Color = col if col is Color else color
	_rect.color = use_col

	var shader_file: String = s.get("shader", "")
	if shader_file == "":
		# plain alpha fade, no shader
		_mat.shader = null
		var from_a := 0.0 if covering else 1.0
		var to_a := 1.0 if covering else 0.0
		_rect.modulate.a = from_a
		var t := create_tween()
		t.tween_property(_rect, "modulate:a", to_a, d)
		await t.finished
	else:
		_rect.modulate.a = 1.0
		_mat.shader = _load_shader(shader_file)
		if s.has("dir"):
			_mat.set_shader_parameter("direction", s["dir"])
		# progress goes 0->1 to cover, 1->0 to reveal
		var from_p := 0.0 if covering else 1.0
		var to_p := 1.0 if covering else 0.0
		_mat.set_shader_parameter("progress", from_p)
		var t := create_tween()
		t.tween_method(func(v): _mat.set_shader_parameter("progress", v), from_p, to_p, d)
		await t.finished
		if not covering:
			_rect.modulate.a = 0.0
	_busy = false


var _shader_cache := {}
func _load_shader(file: String) -> Shader:
	if _shader_cache.has(file):
		return _shader_cache[file]
	var sh: Shader = load(SHADER_DIR + file)
	_shader_cache[file] = sh
	return sh
