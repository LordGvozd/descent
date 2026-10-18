extends Node2D


func _on_run_btn_pressed() -> void:
	var player_code: String = $CanvasLayer/UI/CodeEdit.text
	
	# В скрипте, где вы запускаете код игрока
	var lua := LuaState.new()
	lua.open_libraries() 


	var captured_output: Array[String] = []

	lua.globals["print"] = func(...args):
		var parts: Array[String] = []
		for arg in args:
			parts.append(str(arg))
		captured_output.append(" ".join(parts))

	var result = lua.do_string(player_code)
	
	if result is LuaError:
		captured_output.append("[ERROR] " + result.message)


	for line in captured_output:
		$CanvasLayer/UI/Output.text += ">>>   " +  line + "\n"
