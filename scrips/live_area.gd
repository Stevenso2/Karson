extends Area3D

func _on_body_exited(body: Node3D) -> void:
	print("Respawn command on Body: " + str(body))
	if body.is_in_group("Respawnable") and not global.pause:
		body.Respawn()


func _on_area_exited(area: Area3D) -> void:
	print("Respawn command on Area: " + str(area))
	if area.is_in_group("Respawnable") and not global.pause:
		area.Respawn()
