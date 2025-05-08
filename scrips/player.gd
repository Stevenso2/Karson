extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var shotgun_view: MeshInstance3D = $Camera3D/Shotgun_View
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@export var accelaration = 10

const SPEED = 500.0
const JUMP_VELOCITY = 300.0
var accel = accelaration

const sensitivity = 0.55

var rot_x = 0
var rot_y = 0

var devPos: Vector3
var devspeed = 0.1

func _ready():
	# Hide the mouse cursor and keep it centered.
	set_process_input(true)
	

func _input(event):
	# Check if the event is a mouse motion event.
	if not global.pause:
		if event is InputEventMouseMotion:
			# Adjust the rotation based on the mouse movement.
			rot_x -= event.relative.y * sensitivity
			rot_y -= event.relative.x * sensitivity
			
			# Clamp the x rotation to prevent flipping.
			rot_x = clamp(rot_x, -90, 90)
			
			# Apply the rotation to the camera.
			if global.DEV:
				camera_3d.rotation_degrees.x = rot_x
				camera_3d.rotation_degrees.y = rot_y
			else:
				camera_3d.rotation_degrees.x = rot_x
				rotation_degrees.y = rot_y


func _process(_delta):
	if Input.is_action_just_pressed("Shoot"):
		var SeenObj = ray_cast_3d.get_collider()
		if SeenObj:
			print(SeenObj)
			nudge_object(SeenObj, ray_cast_3d.get_collision_point())

	# If the escape key is pressed, release the mouse.
	if Input.is_action_just_pressed("Esc"):
		if global.pause:
			global.pause = false
		else:
			global.pause = true

func _physics_process(delta: float) -> void:
	if not global.pause && not global.DEV:
		camera_3d.position = Vector3(0,1.65,-0.162)
		camera_3d.rotation.y = 0
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Handle jump.
		if Input.is_action_just_pressed("U") and is_on_floor():
			velocity.y = JUMP_VELOCITY * delta
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_vector("L", "R", "F", "B", 0).normalized()
		
		if direction:
			var ground_vel = Vector2(direction.x, direction.y).rotated(-rotation.y) * SPEED * delta
			velocity = Vector3(ground_vel.x, velocity.y, ground_vel.y) / accel
			if accel > 1:
				accel -= 1

		else:
			accel = accelaration
			velocity.z = move_toward(velocity.z, 0, SPEED)
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		move_and_slide()

	if global.DEV:
		if Input.is_action_pressed("U") and is_on_floor():
			devPos.y += delta
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var dir = Input.get_vector("L", "R", "F", "B", 0).normalized()
		var zdir = Vector2(dir.y, 0).rotated(-camera_3d.rotation.x-90)
		dir = Vector2(dir.x, dir.y).rotated(-camera_3d.rotation.y)
		devPos.x += dir.x * devspeed
		devPos.z += dir.y * devspeed
		devPos.y += zdir.x * devspeed
		camera_3d.position = devPos
		
func nudge_object(collider, collision_point: Vector3):
	if collider is RigidBody3D:
		# Apply an impulse at the collision point
		var direction = (collision_point - ray_cast_3d.global_transform.origin).normalized()
		collider.apply_impulse(collision_point - collider.global_transform.origin, direction * -20)  # Adjust the force magnitude (10)
		var movement = (camera_3d.global_transform.origin - collider.global_transform.origin).normalized()
		collider.apply_central_impulse(Vector3(movement.x, 0.1, movement.z) * -20)
	else:
		# If it's not a RigidBody3D, adjust its position slightly
		collider.global_transform.origin += Vector3(0, 0.1, 0)  # Example: nudges upward slightly
		
