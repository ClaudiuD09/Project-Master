extends MultiplayerSynchronizer

@export var jumping := false

# Synchronized property.
@export var direction := Vector2()
@export var camera_3D : Camera2D


var parent_node  # chat
var usrnm = Globals.usrnm
var msg : String


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		camera_3D.make_current()
		
		
		parent_node = get_node("/root/Multiplayer_UI/Chat")
		if parent_node:
			parent_node.visible = true
		
		
		
		
		if (Globals.mode == 1) and is_multiplayer_authority():
			$UI.visible = true
			@warning_ignore("int_as_enum_without_cast")
			$UI.process_mode = 0
	else:
		set_process(false)
		set_process_input(false)



@rpc("call_local")
func jump():
	jumping = true


func _process(_delta):
	
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#Globals.focus_chat verifica daca este in chat
	if !Globals.focus_chat:
		if Input.is_action_just_pressed("ui_accept"):
			jump.rpc()
	else:
		if Input.is_action_just_pressed("Enter"):
			Globals.emit_signal("enter_pressed")




