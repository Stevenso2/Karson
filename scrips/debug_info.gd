extends Label

var debug_mode := 0
var update_timer := 0.0

func _process(delta):
	# cycle debug modes with F3, Shows after 1 second
	if Input.is_action_just_pressed("Debug Info"):
		debug_mode += 1


		if debug_mode > 2:
			debug_mode = 0

	if debug_mode > 0:
		update_timer += delta

		if update_timer >= 1.0:
			update_timer = 0.0

# different names for the debug, can add anything from global aswell
			var fps = Engine.get_frames_per_second()
			var memory = OS.get_static_memory_usage() / 1024.0 / 1024.0
			var level = get_tree().current_scene.name

# different types of debug
			if debug_mode == 1:
				text = "[Basic] \nFPS: %d\nMemory: %.2f MB" % [fps, memory]

			elif debug_mode == 2:
				text = "[Advanced] \nFPS: %d\nMemory: %.2f MB\nLevel: %s" % [fps, memory, level]

	else:
		text =""
