extends CharacterBody3D

@export var speed: float = 2.0
@export var HP = 5
@export var stun_duration: float = 1.0 #this was meant to be used to stun billy for a second so he wont move when you are ontop of him

var player: Node3D
var stun_timer := 0.0 #this is part 2 of it, basically the main timer "Stun_duration" adds the 1.0 into "stun_timer" which then counts the one second down

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

			# Set velocity and apply movement
			velocity = direction * speed
			move_and_slide()
		else:
			print("Player not assigned")
