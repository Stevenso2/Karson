extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var hud: Control = $Hud

@onready var shotgun_view: RigidBody3D = $Camera3D/Shotgun_View
@onready var sg_anim_player: AnimationPlayer = $Camera3D/SGAnimPlayer

@onready var grapple_view: RigidBody3D = $Camera3D/Grapple_View
@onready var gg_anim_player: AnimationPlayer = $Camera3D/GGAnimPlayer
@onready var grapple_rope: MeshInstance3D = $"Camera3D/Grapple Rope"

@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var ReadyTimer = $Camera3D/ReadySateTimer
@onready var slomo_timer: Timer = $"Slomo Timer"

@export var accelaration = 10
@export var decelaration = 0.02

const SGJUMP = 600.0
const SPEED = 500.0
const JUMP_VELOCITY = 300.0
const SLIDE_SPEED = 1000.0  # increased speed during sliding
const SWING_SPEED = 600.0
const SLIDE_HEIGHT = 0.5    # lower height when sliding
const NORMAL_HEIGHT = 1.66  # normal height when not sliding

var RESPAWN_POS: Vector3
var RESPAWN_ROT: Vector3

var accel = accelaration
var HasSG = false
var HasGG = false
var GGcontact: Vector3
var AllowInteractions = true

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
	RESPAWN_POS = position
	RESPAWN_ROT = rotation
	# Hide the mouse cursor and keep it centered.
	set_process_input(true)
	ReadyTimer.timeout.connect(SGChill)
	slomo_timer.timeout.connect(slomoReset)
	sg_anim_player.play("SG Chill")
	gg_anim_player.play("GG Chill")
	
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
	
	if HasSG:
		hud.shot_gun.show()
	else:
		hud.shot_gun.hide()
	if HasGG:
		hud.grappling_gun.show()
	else:
		hud.grappling_gun.hide()
		
	if HasSG and global.current_Block == global.INV.ShotGun:
		shotgun_view.show()
	else:
		shotgun_view.hide()
	if HasGG and global.current_Block == global.INV.GraplingGun:
		grapple_view.show()
	else:
		grapple_view.hide()

	# If the escape key is pressed, release the mouse.
	if Input.is_action_just_pressed("Esc"):
		if global.pause:
			global.pause = false
		else:
			global.pause = true
			
	if Input.is_action_just_pressed("Slomo"):
		if not global.pause && slomo_timer.time_left == 0:
			if not global.slow:
				global.slow = true
				# take time / slomo ammount to get real time
				slomo_timer.start(5.0 / 4.0)
	
	#Character slide test VERY WIP
	
	if Input.is_action_pressed("sliding test") and is_on_floor() and not is_sliding and not global.DEV:
		is_sliding = true
		camera_3d.position.y = SLIDE_HEIGHT  # Lower camera position to simulate crouch
		if sg_anim_player.assigned_animation == "SG Ready":
			sg_anim_player.play("SG Chill")
			AllowInteractions = true
		if gg_anim_player.assigned_animation == "GG Ready":
			gg_anim_player.play("GG Chill")
			AllowInteractions = true

	# Stop sliding when the Ctrl key is released.
	elif Input.is_action_just_released("sliding test") and is_sliding:
		is_sliding = false
		camera_3d.position.y = NORMAL_HEIGHT  # Reset camera position

func _physics_process(delta: float) -> void:
	var AppliedDelta = ((delta * 4.0) if global.slow else delta)
	#Only Remove "global.DEV" when it is not needed anymore [finally this is fixed god]
	if not global.DEV:
		if not is_sliding and not global.DEV and not is_crouching: #idk to why i need to add "and not global.DEV" here. but it is fixing the cam for now. which is good
			camera_3d.position = Vector3(0,1.69,-0.19)
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
			velocity.y += JUMP_VELOCITY * AppliedDelta
		
		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_vector("L", "R", "F", "B", 0).normalized()
		
		#Slide test thing 3 xD (yes i add these to find it later if smt goes horribly wrong lol)
		# If the player is sliding, increase the speed.
		move_speed = SPEED
		if is_sliding:
			move_speed = SLIDE_SPEED

		if direction:
			if is_on_floor():
				var ground_vel = Vector2(direction.x, direction.y).rotated(-rotation.y) * move_speed * delta
				velocity = Vector3(ground_vel.x, velocity.y, ground_vel.y) / accel
				if accel > 1:
					accel -= 1
			else:
				var normVel = Vector2(velocity.x, velocity.z).normalized()
				var VelAngle = normVel.angle_to(Vector2.UP)
				var newVel = Vector2(velocity.x, velocity.z).rotated(VelAngle)
				var ground_vel = Vector2(direction.x, direction.y).rotated(-rotation.y + VelAngle) * move_speed * delta
				newVel.x = (newVel.x + ground_vel.x/10)
				newVel.y = (newVel.y + ground_vel.y/100)
				newVel = newVel.rotated(-VelAngle)
				velocity = Vector3(newVel.x, velocity.y, newVel.y)
		else:
			if is_on_floor():
				accel = accelaration
				velocity.z = move_toward(velocity.z, 0, decelaration*20)
				velocity.x = move_toward(velocity.x, 0, decelaration*20)
			else:
				accel = accelaration
				velocity.z = move_toward(velocity.z, 0, decelaration)
				velocity.x = move_toward(velocity.x, 0, decelaration)
				
		if Input.is_action_just_pressed("Shoot"):
			ReadyTimer.start(5)
			AllowInteractions = false
			if sg_anim_player.assigned_animation == "SG Chill":
				sg_anim_player.play("SG Ready")
			if gg_anim_player.assigned_animation == "GG Chill":
				gg_anim_player.play("GG Ready")
			var SeenObj = ray_cast_3d.get_collider()
			if SeenObj:
				print(SeenObj)
				if HasSG and global.current_Block == global.INV.ShotGun:
					nudge_object(SeenObj, ray_cast_3d.get_collision_point())
					if SeenObj.is_in_group("SG-Jump"):
						velocity = -(ray_cast_3d.get_collision_point() - ray_cast_3d.global_position).normalized() * SGJUMP * AppliedDelta
					if SeenObj.is_in_group("Stunable"):
						SeenObj.stun.start(1)
						
				if HasGG and global.current_Block == global.INV.GraplingGun:
					GGcontact = ray_cast_3d.get_collision_point()
					grapple_rope.show()
					
		if Input.is_action_just_released("Shoot"):
			grapple_rope.hide()
			GGcontact = Vector3.ZERO
		
		if Input.is_action_pressed("Shoot"):
			if HasGG and global.current_Block == global.INV.GraplingGun:
				if GGcontact != Vector3.ZERO:
					GGSwing(GGcontact, AppliedDelta)
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

func slomoReset():
	if global.slow == true:
		global.slow = false
		slomo_timer.start(15)

func SGChill():
	if sg_anim_player.assigned_animation == "SG Ready":
		sg_anim_player.play("SG Chill")
		AllowInteractions = true
		
func GGChill():
	if gg_anim_player.assigned_animation == "GG Ready":
		gg_anim_player.play("GG Chill")
		AllowInteractions = true
		
func GGSwing(ContactPos: Vector3, AppliedDelta):
	var radial_vector = (position - ContactPos).normalized()
	# Project the velocity onto the tangent plane of the sphere
	var tangential_velocity = velocity - radial_vector * radial_vector.dot(velocity)
	velocity = tangential_velocity.normalized() * velocity.length()
	if Input.is_action_pressed("U"):
		position -= radial_vector * 10 * AppliedDelta

func Respawn():
	position = RESPAWN_POS
	rotation = RESPAWN_ROT
	camera_3d.rotation_degrees.x = 0
	camera_3d.rotation_degrees.y = 0
	rotation_degrees.y = rot_y
