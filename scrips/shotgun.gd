extends RigidBody3D

@export var ShouldColide = true

var RESPAWN_POS: Vector3
var RESPAWN_ROT: Vector3

func _ready() -> void:
	RESPAWN_POS = position
	RESPAWN_ROT = rotation
	
	if !ShouldColide:
		collision_mask = 0x0
		process_mode = Node.PROCESS_MODE_DISABLED

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if !body.HasSG:
			body.HasSG = true
			queue_free()

func Respawn():
	position = RESPAWN_POS
	rotation = RESPAWN_ROT
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	move_and_collide(Vector3.ZERO)
