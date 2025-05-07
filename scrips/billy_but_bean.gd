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
			direction.y = 0  # so the enemy wont jump ("yet")
			direction = direction.normalized()  

			velocity = direction * speed
			move_and_slide()  
		else:
			print("Player not assigned")
