extends MultiplayerSynchronizer


@export var jumping := false
@export var direction := Vector2()

@export var running := false
@export var do_jump := false

var chatting := false
@export var chat := false
@export var movement : bool = true

var runn = false
var parent_node
var input_bool : bool = true

@export var camera_base : Node3D
@export var camera_rotation : Node3D
@export var camera_3D : Camera3D

@export var id_user : int
@export var joystick : VirtualJoystick
#@onready var camera_3d = $Camera_Base/Camera_Rotation/SpringArm3D/Camera3D

const CAMERA_CONTROLLER_ROTATION_SPEED := 3.0
const CAMERA_MOUSE_ROTATION_SPEED := 0.005
const CAMERA_JOYSTICK_ROTATION_SPEED := 0.01
const CAMERA_X_ROT_MIN := deg_to_rad(-50)
const CAMERA_X_ROT_MAX := deg_to_rad(20)
const CAMERA_UP_DOWN_MOVEMENT = 1



func _ready():
	# Only process for the local player
	#set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		
		
		camera_3D.make_current()
		
		parent_node = get_node("/root/Multiplayer_UI/Chat")
		if parent_node:
			parent_node.visible = false
			#print("da")
		
		
		if (Globals.mode == 1) and is_multiplayer_authority():
			$UI.visible = true
			@warning_ignore("int_as_enum_without_cast")
			$UI.process_mode = 0
			
	else:
		set_process(false)
		set_process_input(false)



@rpc("call_local")
func jump():
	#jumping = true
	do_jump = true




func enter_chat():
	parent_node = get_node("/root/Multiplayer_UI/Chat")
	if parent_node != null:
		if chat:
			chat = false
			parent_node.visible = false
		else:
			chat = true
			parent_node.visible = true
	



func _input(event):
	if event is InputEventMouseMotion and (Globals.mode == 0):
		rotate_camera(event.relative * CAMERA_MOUSE_ROTATION_SPEED)
	elif joystick and joystick.is_pressed and (Globals.mode == 1):
		rotate_camera(event.relative * CAMERA_JOYSTICK_ROTATION_SPEED)


func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	camera_base.orthonormalize()
	camera_rotation.rotation.x = clamp(camera_rotation.rotation.x +(CAMERA_UP_DOWN_MOVEMENT * move.y),CAMERA_X_ROT_MIN, CAMERA_X_ROT_MAX)



func get_camera_rotation_basis() -> Basis:
	return camera_rotation.global_transform.basis





func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#verific daca sunt in chat
	if !Globals.focus_chat:
		if Input.is_action_just_pressed("ui_accept"):
			jump.rpc()
		
		if Input.is_action_just_pressed("chat"):
			enter_chat()
			#to do - add signal to get focus on lineEdit
		
	else:
		if Input.is_action_just_pressed("Enter"):
			Globals.emit_signal("enter_pressed")
	
	
	
	if Input.is_action_pressed("run") or runn:
		running = true
	elif !Input.is_action_pressed("run") and !runn:
		running = false
	
	











