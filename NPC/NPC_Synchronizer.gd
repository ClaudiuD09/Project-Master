extends MultiplayerSynchronizer

var TARGET_ACTIVE

@onready var npc = $".."

func _on_body_entered(body):
	if not is_inside_tree() or not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		return
	
	if body.is_in_group("Player") && TARGET_ACTIVE == null:
		TARGET_ACTIVE = body.player
		#print("body entered")
		npc.set_target_player(body)
		


func _on_body_exited(body):
	if not is_inside_tree() or not multiplayer.has_multiplayer_peer() or not is_multiplayer_authority():
		return
	
	if body.is_in_group("Player") && TARGET_ACTIVE == body.player:
		TARGET_ACTIVE = null
		#print("body exited")
		npc.set_target_player(null)
