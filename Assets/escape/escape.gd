extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_body_entered(body):
	if is_multiplayer_authority():
		@warning_ignore("shadowed_global_identifier")
		var str = String(body.name)
		var id = int(str)
		#print(id)
		Globals.emit_signal("area_signal", id)








