extends CharacterBody3D

@export var speed: float = 2.0

var player: Node3D 

func _ready():
	
	# Find the player in the "player" group
	var players = get_tree().get_nodes_in_group("Player")
	
	if players.size() > 0:
		player = players[0] # Assume there is only one player, for right now it is but soon will be changed
	else:
		print("No player found in the group")

func _physics_process(delta):
	if not global.pause:
		if player:
			var direction = player.global_transform.origin - global_transform.origin
			direction.y = 0
			direction = direction.normalized()

			# Rotate only on Y axis
			var target_pos = player.global_transform.origin
			target_pos.y = global_transform.origin.y
			look_at(target_pos, Vector3.UP)
			rotation_degrees.y += 90

			# Set velocity and apply movement
			velocity = direction * speed
			move_and_slide()
		else:
			print("Player not assigned")
