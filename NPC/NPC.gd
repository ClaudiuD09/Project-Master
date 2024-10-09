class_name NPC extends CharacterBody3D


const NPC_WALK_SPEED = 3.0
const JUMP_VELOCITY = 4.5


enum ANIMATIONS { RUN, WALK, IDLE, DIE }
@export var current_animation := ANIMATIONS.IDLE
@onready var model = $root_model/model
@onready var animation_tree = $AnimationTree

@onready var eye_left = $root_model/model/head/eye_left
@onready var eye_right = $root_model/model/head/eye_right


var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var target_player
var target_player_position
var orientation = Transform3D()


func _ready():
	orientation = model.global_transform
	orientation.origin = Vector3()
	
	if not multiplayer.is_server():
		set_process(false)


func _process(_delta):
	if target_player != null:
		target_player_position = target_player.transform.origin

func set_target_player(player):
	target_player = player
	if target_player != null:
		target_player_position = target_player.transform.origin



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if multiplayer.is_server():
		_apply_movement(delta)
	else:
		_animate(current_animation)




func _apply_movement(_delta):
	if target_player != null:
		
		var direction = target_player.global_transform.origin
		direction.y = 1
		
		
		#loot_direction
		look_at(direction, Vector3.UP)
		
		
		
		#movement
		if is_on_floor():
			var player_direction = global_transform.origin.direction_to(direction)
			player_direction *= NPC_WALK_SPEED
			velocity = player_direction
			set_up_direction(Vector3.UP)
			
			_animate(ANIMATIONS.RUN)
	
	else:
		velocity.x *= 0
		velocity.z *= 0
		
		_animate(ANIMATIONS.IDLE)
	
	
	move_and_slide()

func _animate(anim: int):
	@warning_ignore("int_as_enum_without_cast")
	current_animation = anim
	
	
	if anim == ANIMATIONS.WALK:
		animation_tree.set("parameters/state/transition_request", "walk")
	elif anim == ANIMATIONS.RUN:
		#to do eye color change
		animation_tree.set("parameters/state/transition_request", "run")
	elif anim == ANIMATIONS.DIE:
		animation_tree.set("parameters/state/transition_request", "die")
	elif anim == ANIMATIONS.IDLE:
		animation_tree.set("parameters/state/transition_request", "idle")
		









