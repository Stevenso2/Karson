extends RigidBody3D

@export var speed: float = 300.0
@onready var stun = $Timer

var RESPAWN_POS: Vector3
var RESPAWN_ROT: Vector3

var player: Node3D

# True while Billy is being held by the player
var being_held := false


func _ready():
	RESPAWN_POS = position
	RESPAWN_ROT = rotation

	# Find the player in the "Player" group
	var players = get_tree().get_nodes_in_group("Player")

	if players.size() > 0:
		player = players[0] # Assume there is only one player for now
	else:
		print("No player found in the group")


func _physics_process(delta):
	if not global.pause:
		# Billy stops chasing the player while being held
		if player and stun.time_left == 0 and not being_held:
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
				linear_velocity.x = move_toward(
					linear_velocity.x,
					0,
					speed / 1000
				)

				linear_velocity.z = move_toward(
					linear_velocity.z,
					0,
					speed / 1000
				)

		elif not player:
			print("Player not assigned")


# Called by player.gd when Billy is picked up or dropped
func set_being_held(value: bool) -> void:
	being_held = value

	if value:
		# Immediately stop Billy's movement when picked up
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO


func Respawn():
	position = RESPAWN_POS
	rotation = RESPAWN_ROT
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	# Make sure Billy can move again after respawning
	being_held = false
