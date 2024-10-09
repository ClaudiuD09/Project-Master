extends Node2D

var parent_chat
var parent_players
var parent_start
var start


# Called when the node enters the scene tree for the first time.
func _ready():
	
	parent_players = get_node("/root/Multiplayer_UI/Chat/VBoxContainer/ColorRect/Number_Of_Players")
	parent_start = get_node("/root/Multiplayer_UI/Start_UI")
	start = get_node("/root/Multiplayer_UI/Start_UI/Start_game")
	
	#Chat
	parent_chat = get_node("/root/Multiplayer_UI/Chat/VBoxContainer/Chat")
	if multiplayer.is_server():
		parent_chat.clean()
	
	
	
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)
	
	
	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
		
	



func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	



func add_player(id: int):
	#randomize()
	
	#give time to load library
	if id != 1:
		await get_tree().create_timer(0.1).timeout
	
	
	
	parent_chat.send_data("Add player: " + str(PlayerManager.Players[id].name))
	#print("Add player: " + str(id))
	var character = preload("res://Player_2D/player_2d.tscn").instantiate()
	
	
	# Set player id.
	character.player = id
	
	var rand_x = randf_range(-400,400)
	var rand_y = randf_range(-300,300)
	character.position = Vector2(rand_x, rand_y)
	
	character.name = str(id)
	
	$Spawn.add_child(character, true)
	
	Globals.number_players += 1
	rpc("update", Globals.number_players)



func del_player(id: int):
	
	parent_chat.send_data("Remove player: " + str(PlayerManager.Players[id].name))
	
	if not $Spawn.has_node(str(id)):
		return
	$Spawn.get_node(str(id)).queue_free()
	
	
	Globals.number_players -= 1
	rpc("update", Globals.number_players)
	

@rpc ("any_peer","call_local")
func update(count):
	if count > 1 && is_multiplayer_authority():
		parent_start.visible = true
		start.set_process_mode(PROCESS_MODE_ALWAYS)
		start.disabled = false
		
		
		
	elif count <= 1 && is_multiplayer_authority():
		parent_start.visible = true
		start.set_process_mode(PROCESS_MODE_DISABLED)
		start.disabled = true
	
	parent_players.text = "Players: " + str(count) + "/4"
	



