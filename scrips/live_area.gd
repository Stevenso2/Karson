extends Area3D

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Respawnable") and not global.pause and global.ingame:
		print("Respawn command on Body: " + str(body))
		body.Respawn()


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("Respawnable") and not global.pause and global.ingame:
		print("Respawn command on Area: " + str(area))
		area.Respawn()
