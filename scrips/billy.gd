extends RigidBody3D

@export var speed: float = 300.0
@onready var stun = $Timer

var RESPAWN_POS: Vector3
var RESPAWN_ROT: Vector3

var player: Node3D
func _ready():
	RESPAWN_POS = position
	RESPAWN_ROT = rotation
	
	# Find the player in the "player" group
	var players = get_tree().get_nodes_in_group("Player")
	
	if players.size() > 0:
		player = players[0] # Assume there is only one player, for right now it is but soon will be changed
	else:
		print("No player found in the group")

func _physics_process(delta):
	if not global.pause:
		if player and stun.time_left == 0:
			var direction = player.global_transform.origin - global_transform.origin
			direction.y = 0
			direction = direction.normalized()

			# Rotate only on Y axis
			var target_pos = player.global_transform.origin
			target_pos.y = global_transform.origin.y
			look_at(target_pos, Vector3.UP)

			# Set velocity and apply movement
			var dist = global_transform.origin.distance_to(player.global_transform.origin)
			if dist > 2:
				linear_velocity.x = direction.x * speed * delta
				linear_velocity.z = direction.z * speed * delta
			else:
				linear_velocity.x = move_toward(linear_velocity.x, 0, speed/1000)
				linear_velocity.z = move_toward(linear_velocity.z, 0, speed/1000)
		elif not player:
			print("Player not assigned")
			
func Respawn():
	position = RESPAWN_POS
	rotation = RESPAWN_ROT
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
