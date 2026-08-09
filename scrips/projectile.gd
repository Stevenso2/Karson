extends Area3D

@export var speed: float = 2.0
@export var lifetime: float = 0.3

var direction := Vector3.ZERO


func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout

	if is_inside_tree():
		queue_free()


func _physics_process(delta: float) -> void:
	var old_position = global_position
	var new_position = old_position + direction * speed * delta

	# check everything between the projectiles old and new position
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(
		old_position,
		new_position
	)

	# Dont hit the player who fired the pellet
	query.exclude = [get_tree().get_first_node_in_group("Player")]

	var result = space_state.intersect_ray(query)

	if result:
		# projectile hiting something
		global_position = result.position
		queue_free()
		return

	# nothing was hit so continue moving
	global_position = new_position
