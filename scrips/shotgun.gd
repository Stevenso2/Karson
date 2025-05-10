extends RigidBody3D

@export var ShouldColide = true

func _ready() -> void:
	if !ShouldColide:
		collision_mask = 0x0
		process_mode = Node.PROCESS_MODE_DISABLED

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if !body.HasSG:
			body.HasSG = true
			queue_free()
