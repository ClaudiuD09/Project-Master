class_name Player extends CharacterBody3D


var SPEED = 5.0
var RUN_SPEED = 15.0
const JUMP_VELOCITY = 4.5
const ACCELERATION = 15

const DIRECTION_INTERPOLATE_SPEED = 1
const MOTION_INTERPOLATE_SPEED = 10
const ROTATION_INTERPOLATE_SPEED = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var motion = Vector2()
var orientation = Transform3D()
var movement : bool = true

var parent_node

enum ANIMATION { JUMP, WALK }
@export var current_animation := ANIMATION.WALK
var self_name 

# Player synchronized input.
@onready var input = $PlayerInput
@onready var player_model = $Player_model
@onready var animation_tree = $AnimationTree
@onready var corp = $Player_model/corp


@export var color: Color:
	set(value):
		color = value
		apply_color()


# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)



func _ready():
	#animation_tree.active = true
	#orientation = player_model.global_transform
	#orientation.origin = Vector3()
	Globals.connect("area_signal", Callable(self, "_area_send"))
	movement = true
	
	if not multiplayer.is_server():
		set_process(false)
	
	apply_color()



#to change color to the mesh
func apply_color():
	#var material = corp.get_active_material(0)
	if corp:
		var material = corp.get_active_material(0)
		if material == null:
			material = StandardMaterial3D.new()
			material.albedo_color = color
			corp.set_surface_override_material(0, material)




func _physics_process(delta):
	
	if movement == true:
		SPEED = 5.0
		RUN_SPEED = 15.0
	else:
		SPEED = 0.0
		RUN_SPEED = 0.0
	
	
	
	if multiplayer.is_server():
		_apply_input(delta)
	else:
		animate(current_animation, delta)
		
	
	






func _apply_input(delta: float):
	
	
	
	#motion code
	motion = motion.lerp(input.direction, MOTION_INTERPOLATE_SPEED * delta)
	
	var camera_basis : Basis = input.get_camera_rotation_basis()
	var camera_z := camera_basis.z
	var camera_x := camera_basis.x
	
	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not input.jumping && input.do_jump && is_on_floor():
		input.do_jump = false
		input.jumping = true
	elif input.jumping and is_on_floor():
		animate(ANIMATION.JUMP, delta)
		velocity.y = JUMP_VELOCITY
		input.jumping = false
	elif is_on_floor():
		animate(ANIMATION.WALK, delta )
	
	var target = camera_x * motion.x + camera_z * motion.y
	
	
	
	if target.length() > 0.001:
		var q_from = orientation.basis.get_rotation_quaternion()
		var q_to = Transform3D().looking_at(target, Vector3.UP).basis.get_rotation_quaternion()
		
		orientation.basis = Basis(q_from.slerp(q_to, delta * ROTATION_INTERPOLATE_SPEED))
	
	
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	
	var speed = RUN_SPEED if input.running else SPEED
	
	camera_basis = camera_basis.rotated(camera_basis.x, -camera_basis.get_euler().x)
	
	var direction = (camera_basis * Vector3(motion.x, 0, motion.y))
	var position_target = direction * speed
		
	if direction.length() < 0.01:
		horizontal_velocity = Vector3.ZERO
	else:
		horizontal_velocity = horizontal_velocity.lerp(position_target, ACCELERATION * delta)
	
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	
	
	
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	orientation.origin = Vector3()
	orientation = orientation.orthonormalized()
	player_model.global_transform.basis = orientation.basis
	




@warning_ignore("unused_parameter")
func animate(anim: int, delta := 0.0 ):
	@warning_ignore("int_as_enum_without_cast")
	current_animation = anim
	
	var is_running = 0
	if input.running:
		is_running = 1
	
	if anim == ANIMATION.JUMP:
		animation_tree.set("parameters/state/transition_request", "jump")
	elif anim == ANIMATION.WALK:
		animation_tree.set("parameters/state/transition_request", "walk")
		animation_tree.set("parameters/walk/blend_position", Vector2(motion.length(), is_running))
		




#stop/freeze function
func _area_send(id):
	self_name = self.get_name()
	
	#conversion from .name to string	
	@warning_ignore("shadowed_global_identifier")
	var str = String(self_name)
	self_name = int(str)
	
	if self_name == id:
		movement = false
		





