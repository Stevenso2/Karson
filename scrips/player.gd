extends CharacterBody3D

@onready var camera_3d: Camera3D = $Camera3D
@onready var hud: Control = $Hud

@onready var shotgun_view: RigidBody3D = $Camera3D/Shotgun_View
@onready var sg_anim_player: AnimationPlayer = $Camera3D/SGAnimPlayer

@onready var grapple_view: RigidBody3D = $Camera3D/Grapple_View
@onready var gg_anim_player: AnimationPlayer = $Camera3D/GGAnimPlayer
@onready var grapple_rope: MeshInstance3D = $"Camera3D/Grapple Rope"
@onready var grapple_muzzle: Marker3D = $"Camera3D/Grapple_View/Grapple Muzzle"

@onready var grapple_ray: RayCast3D = $Camera3D/GrappleRay
@onready var shotgun_ray: RayCast3D = $Camera3D/ShotgunRay

@onready var ReadyTimer = $Camera3D/ReadySateTimer
@onready var slomo_timer: Timer = $"Slomo Timer"
@onready var pmp_sync: MultiplayerSynchronizer = $PMP_sync
@onready var wall_jump_timer: Timer = $"WallJump Timer"

#To make sliding work better
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var sliding_collision: CollisionShape3D = $Sliding_Collision
@onready var body_anim_player: AnimationPlayer = $Karlson/BodyAnimationPlayer

@export var accelaration = 10
@export var decelaration = 0.02

const SGJUMP = 950.0
const SPEED = 500.0
const JUMP_VELOCITY = 300.0
const SLIDE_SPEED = 750.0  # increased speed during sliding
const SWING_SPEED = 600.0
const SLIDE_HEIGHT = 0.5    # lower height when sliding
const NORMAL_HEIGHT = 1.66  # normal height when not sliding

var RESPAWN_POS: Vector3
var RESPAWN_ROT: Vector3

var accel = accelaration
var HasSG = false
var HasGG = false
var GGcontact: Vector3
var GGSeenObj: Node3D
var AllowInteractions = true

const sensitivity = 0.35 # 0.55 for school mouse, 0,35 for my own mouse -Pizzi

var rot_x = 0
var rot_y = 0

var devPos: Vector3
var devspeed = 0.1

var grav = Vector3(0,-1,0)

var move_speed = SPEED
#var direction:int = 0
var is_sliding: bool = false
var is_crouching: bool = false  # track if the player is crouching

func _ready():
	global.transition = $Karlson/BodyAnimationPlayer # used for making the sliding now work properly 
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
			Camara(event)
			

#@rpc("any_peer", "call_local", "reliable")
func Camara(event):
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
	grav = get_gravity()
	
	if is_sliding:
		move_speed = SLIDE_SPEED
	
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
				
	if Input.is_action_just_pressed("intercat") and not global.DEV:
		print("intercat test")
		var interact: Area3D = shotgun_ray.get_collider()
		if interact and interact.is_class("Area3D"):
			if interact.get_parent().has_method("Intercat"):
				print("intercat")
				interact.get_parent().Intercat()
	
	#Character slide test VERY WIP
	
	if Input.is_action_pressed("sliding test") and is_on_floor() and not is_sliding and not global.DEV:
		is_sliding = true
		camera_3d.position.y = SLIDE_HEIGHT  # Lower camera position to simulate crouch < del if animation works
		
		#animation play
		body_anim_player.play("slide")
		
		#switch collisionshapes 
		sliding_collision.disabled = false
		collision_shape.disabled = true
		
		
		if sg_anim_player.assigned_animation == "SG Ready":
			sg_anim_player.play("SG Chill")
			AllowInteractions = true
		if gg_anim_player.assigned_animation == "GG Ready":
			gg_anim_player.play("GG Chill")
			AllowInteractions = true

	# Stop sliding when the Ctrl key is released.
	elif not Input.is_action_pressed("sliding test") and is_sliding and is_on_floor():
	# reset collision shapes 
		sliding_collision.disabled = true
		collision_shape.disabled = false
		is_sliding = false
		camera_3d.position.y = NORMAL_HEIGHT  # Reset camera position < del if animation works
		
		
		
		#reset animation
		body_anim_player.play("Walk")

func _physics_process(delta: float) -> void:
	delta += 0.000001
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
			velocity += grav * delta
		
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
	
		if is_on_wall_only() and Input.is_action_pressed("U") and wall_jump_timer.time_left <= 0 and get_slide_collision(0).get_collider().is_in_group("WallJumpable") :
			#grav *= 1.25
			print("help")
			var bounce_angle: Vector3 = get_slide_collision(0).get_normal()
			var DeltaAngle = abs(int(rad_to_deg(Vector2(bounce_angle.x, bounce_angle.z).angle_to(Vector2.UP)) - rad_to_deg(rotation.y)) % 180)
			print(DeltaAngle)
			if is_sliding and 110 > DeltaAngle and DeltaAngle > 70:
				print("end help")
				velocity.y += (JUMP_VELOCITY*2) # test
				velocity += bounce_angle * 15
				wall_jump_timer.start(0.5)
			else:
				print("start help")
				velocity.y += JUMP_VELOCITY/30 # test 2
				wall_jump_timer.start(1)

		if direction:
			if is_on_floor():
				if velocity.length() < 9:
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
					velocity.z = move_toward(newVel.y, 0, decelaration*7)
					velocity.x = move_toward(newVel.x, 0, decelaration*7)
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
				velocity.z = move_toward(velocity.z, 0, decelaration*10)
				velocity.x = move_toward(velocity.x, 0, decelaration*10)
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
			GGSeenObj = grapple_ray.get_collider()
			if GGSeenObj and HasGG and global.current_Block == global.INV.GraplingGun:
				print(GGSeenObj)
				GGcontact = grapple_ray.get_collision_point()
				grapple_rope.show()
			
			var SGSeenObj = shotgun_ray.get_collider()
			if SGSeenObj and HasSG and global.current_Block == global.INV.ShotGun:
					nudge_object(GGSeenObj, grapple_ray.get_collision_point())
					if GGSeenObj.is_in_group("SG-Jump"):
						velocity = -(shotgun_ray.get_collision_point() - shotgun_ray.global_position).normalized() * SGJUMP * AppliedDelta
					if GGSeenObj.is_in_group("Stunable"):
						GGSeenObj.stun.start()
					
		if Input.is_action_just_released("Shoot"):
			grapple_rope.hide()
			GGcontact = Vector3.ZERO
		
		if Input.is_action_pressed("Shoot"):
			if HasGG and global.current_Block == global.INV.GraplingGun:
				if GGSeenObj:
					var contact = Vector3(0,0,0)
					if GGSeenObj.is_in_group("GG-Pull"):
						if GGcontact != Vector3.ZERO:
							contact = GGcontact
							GGSwing(GGcontact, AppliedDelta)
					if GGSeenObj.is_in_group("PObj"):
						contact = GGSeenObj.position
						GGSwing(GGSeenObj.position, AppliedDelta)
						
					var dir = (contact - grapple_muzzle.global_transform.origin).normalized()
					var newbasis = Basis()
					newbasis.z = dir # Forward (+Z)
					newbasis.x = Vector3.UP.cross(dir).normalized()  # Right (+X)
					newbasis.y = dir.cross(newbasis.x).normalized()  # Up (+Y)
					grapple_rope.global_transform.basis = newbasis
					grapple_rope.rotate_object_local(Vector3.RIGHT, deg_to_rad(-90))
					grapple_rope.scale = Vector3(0.025,grapple_muzzle.global_transform.origin.distance_to(contact),0.025)
					grapple_rope.global_position = (grapple_muzzle.global_position + contact)/2
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
		var dir = (collision_point - shotgun_ray.global_transform.origin).normalized()
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
	# Apply gravity
	velocity += get_gravity() * AppliedDelta
	if Input.is_action_pressed("U"):
		position -= radial_vector * 10 * AppliedDelta

func Respawn():
	print("Player " + str(name) + " has respawned")
	position = RESPAWN_POS
	rotation = RESPAWN_ROT
	camera_3d.rotation_degrees.x = 0
	camera_3d.rotation_degrees.y = 0
	rotation_degrees.y = rot_y
