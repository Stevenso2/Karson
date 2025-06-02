extends Area3D

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Respawnable") and not global.pause and global.ingame and not global.transition.is_playing(): # global.transition.is.playing() for stopping this script to make the player not respawn each time
		print("Respawn command on Body: " + str(body))
		if body.has_method("Respawn"):
			body.Respawn()

func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Respawnable") and not global.pause and global.ingame:
		print("Respawn command on Area: " + str(area))
		if area.has_method("Respawn"):
			area.Respawn()
