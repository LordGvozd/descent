@tool
extends EditorPlugin
## Registers the `Transition` autoload when the plugin is enabled, and removes it
## when disabled. Guarded so it won't clash if the project already defines it.

const AUTOLOAD_NAME := "Transition"
const AUTOLOAD_PATH := "res://addons/saltmire_transitions/transition.gd"

func _enter_tree() -> void:
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

func _exit_tree() -> void:
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)
