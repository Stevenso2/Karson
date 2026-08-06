extends Label
# uses global.debug_mode to save between levels, but still takes around 1 second to show up on lvl reloads.
var update_timer := 0.0

func _process(delta):
	# cycle debug modes with F3, Shows after ~1 second
	if Input.is_action_just_pressed("Debug Info"):
		global.debug_mode += 1


		if global.debug_mode > 2:
			global.debug_mode = 0

	if global.debug_mode > 0:
		update_timer += delta

		if update_timer >= 0.5: # Change this amount to how many times you wanna update the fps counter etc
			update_timer = 0.0
			# different names for the debug, can add anything from global aswell
			var fps = Engine.get_frames_per_second()
			var memory = OS.get_static_memory_usage() / 1024.0 / 1024.0
			var level = get_tree().current_scene.name
			var speed = global.current_speed

# different types of debug
			if global.debug_mode == 1:
				text = "[Basic] \nFPS: %d\nMemory: %.2f MB" % [fps, memory]

			elif global.debug_mode == 2:
				text = "[Advanced] \nFPS: %d\nMemory: %.2f MB\nSpeed: %.2f m/s\nLevel: %s" % [fps, memory, speed, level]

	else:
		text =""
