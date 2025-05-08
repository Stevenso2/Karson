extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var shotgun_view: MeshInstance3D = $Camera3D/Shotgun_View
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@export var accelaration = 10

const SPEED = 500.0
const JUMP_VELOCITY = 300.0
const SLIDE_SPEED = 1000.0  # increased speed during sliding
const SLIDE_HEIGHT = 0.5    # lower height when sliding
const NORMAL_HEIGHT = 1.66  # normal height when not sliding

var accel = accelaration

const sensitivity = 0.35 # 0.55 for school mouse, 0,35 for my own mouse -Pizzi

var rot_x = 0
var rot_y = 0

var devPos: Vector3
var devspeed = 0.1

var move_speed = SPEED
#var direction:int = 0
var is_sliding: bool = false
var is_crouching: bool = false  # track if the player is crouching

func _ready():
	# Hide the mouse cursor and keep it centered.
	set_process_input(true)
	add_to_group("Player")
	

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
	if is_sliding:
		move_speed = SLIDE_SPEED


func _process(_delta):
	if Input.is_action_just_pressed("Shoot"):
		var SeenObj = ray_cast_3d.get_collider()
		if SeenObj:
			#print(SeenObj)
			nudge_object(SeenObj, ray_cast_3d.get_collision_point())

	# If the escape key is pressed, release the mouse.
	if Input.is_action_just_pressed("Esc"):
		if global.pause:
			global.pause = false
		else:
			global.pause = true
	
	#Character slide test VERY WIP
	
	if Input.is_action_pressed("sliding test") and is_on_floor() and not is_sliding and not global.DEV:
		is_sliding = true
		camera_3d.position.y = SLIDE_HEIGHT  # Lower camera position to simulate crouch

	# Stop sliding when the Ctrl key is released.
	elif Input.is_action_just_released("sliding test") and is_sliding:
		is_sliding = false
		camera_3d.position.y = NORMAL_HEIGHT  # Reset camera position

func _physics_process(delta: float) -> void:
	#Only Remove "global.DEV" when it is not needed anymore [finally this is fixed god]
	if not global.pause and not global.DEV:
		if not is_sliding and not global.DEV and not is_crouching: #idk to why i need to add "and not global.DEV" here. but it is fixing the cam for now. which is good
			camera_3d.position = Vector3(0,1.65,-0.165)
			camera_3d.rotation.y = 0
		
		#Still Sliding test
		# Adjust camera height based on sliding state
		if is_sliding and not global.DEV:
			Vector3(0,SLIDE_HEIGHT,0) 
		else:
			Vector3(0,NORMAL_HEIGHT,0)
		
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		# Handle jump.
		if Input.is_action_just_pressed("U") and is_on_floor():
			velocity.y = JUMP_VELOCITY * delta
		
		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_vector("L", "R", "F", "B", 0).normalized()
		
		#Slide test thing 3 xD (yes i add these to find it later if smt goes horribly wrong lol)
		# If the player is sliding, increase the speed.
		move_speed = SPEED
		if is_sliding:
			move_speed = SLIDE_SPEED

		if direction:
			var ground_vel = Vector2(direction.x, direction.y).rotated(-rotation.y) * move_speed * delta
			velocity = Vector3(ground_vel.x, velocity.y, ground_vel.y) / accel
			if accel > 1:
				accel -= 1
		else:
			accel = accelaration
			velocity.z = move_toward(velocity.z, 0, move_speed)
			velocity.x = move_toward(velocity.x, 0, move_speed)
		
		move_and_slide()

	if global.DEV:
		if Input.is_action_pressed("U") and is_on_floor() and not is_crouching and not is_sliding:
			devPos.y += delta
		
		# Get the input direction and handle the movement/deceleration.
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
		var dir = (collision_point - ray_cast_3d.global_transform.origin).normalized()
		collider.apply_impulse(collision_point - collider.global_transform.origin, dir * -20)  # Adjust the force magnitude (10)
		var movement = (camera_3d.global_transform.origin - collider.global_transform.origin).normalized()
		collider.apply_central_impulse(Vector3(movement.x, 0.1, movement.z) * -20)
	else:
		# If it's not a RigidBody3D, adjust its position slightly
		collider.global_transform.origin += Vector3(0, 0.1, 0)  # Example: nudges upward slightly
 
