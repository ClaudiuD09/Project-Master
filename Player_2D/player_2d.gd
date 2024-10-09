extends CharacterBody2D


@export var speed = 400


# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)


# Player synchronized input.
@onready var input = $PlayerInput

func _ready():
	
	if not multiplayer.is_server():
		set_process(false)
	



func _physics_process(_delta):
	if input.jumping:
		print("jump")
	
	input.jumping = false
	velocity = input.direction * speed
	move_and_slide()




