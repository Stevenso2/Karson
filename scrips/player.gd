extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D

const SPEED = 500.0
const JUMP_VELOCITY = 300.0

const sensitivity = 0.55

var rot_x = 0
var rot_y = 0

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
			camera_3d.rotation_degrees.x = rot_x
			rotation_degrees.y = rot_y


func _process(_delta):
	# If the escape key is pressed, release the mouse.
	if Input.is_action_just_pressed("Esc"):
		if global.pause:
			global.pause = false
		else:
			global.pause = true

func _physics_process(delta: float) -> void:
	if not global.pause:
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
			velocity = Vector3(ground_vel.x, velocity.y, ground_vel.y)

		else:
			velocity.z = move_toward(velocity.z, 0, SPEED)
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		move_and_slide()
