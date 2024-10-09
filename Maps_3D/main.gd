extends Node3D

var parent_chat
var parent_players
var leaderboard
var table

var count : int
const SPAWN_RANDOM := 5.0

const NPC_SCENE = "res://NPC/NPC.tscn"
const NPC_SPAWN_COUNT = 20


var player_0 = preload("res://Player_3D/player_3d.tscn")
var player_1 = preload("res://Player_3D/player_3d_1.tscn")

var game_ui


func _ready():
	#print("Map Ready")
	Globals.connect("area_signal", Callable(self, "_area_send"))
	
	#Number_Of_Players
	parent_players = get_node("/root/Multiplayer_UI/Chat/VBoxContainer/ColorRect/Number_Of_Players")
	Globals.number_players = 0
	
	#Game UI Server
	game_ui = get_node("/root/Multiplayer_UI/Game_Buttons")
	
	#CHAT
	parent_chat = get_node("/root/Multiplayer_UI/Chat/VBoxContainer/Chat")
	if multiplayer.is_server():
		parent_chat.clean()
	
	
	#Leaderboard_Table
	table = get_node("/root/Multiplayer_UI/Leaderboard/Control/Table")
	leaderboard = get_node("/root/Multiplayer_UI/Leaderboard")
	leaderboard.visible = true
	
	#reset count
	count = 1
	
	
	# We only need to spawn players on the server.
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
	
	
	
	_spawn_npc.call_deferred(NPC_SPAWN_COUNT)
	




func _spawn_npc(spawn_amount: int):
	
	
	for n in spawn_amount:
		var npc = preload(NPC_SCENE).instantiate()
		
		#not yet implemented
		var rng = RandomNumberGenerator.new()
		var _random_x = rng.randf_range(-20.0, 20.0)
		var _random_z = rng.randf_range(-20.0, 20.0)
		
		var _random_rotation_y = rng.randf_range(0.0, 360.0)
		
		#for test
		npc.position = Vector3(_random_x, 3, _random_z)
		npc.rotation_degrees.y = _random_rotation_y
		
		
		npc.name = str(n + 10)
		$NPC_spawn.add_child(npc, true)







func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)




func add_player(id: int):
	#waiting time, to give the app time to process the info from library
	await get_tree().create_timer(0.2).timeout
	
	parent_chat.send_data("Add player: " + str(PlayerManager.Players[id].name))
	
	
	#Character color change
	var character
	if PlayerManager.Players[id].Character_2D == 1:
		character = player_1.instantiate()
		character.color = PlayerManager.Players[id].color
	elif PlayerManager.Players[id].Character_2D == 2:
		character = player_1.instantiate()
		character.color = PlayerManager.Players[id].color
	elif PlayerManager.Players[id].Character_2D == 0:
		character = player_0.instantiate()
	
	
	# Set player id.
	character.player = id
	
	# Randomize character position.
	# need rework
	var pos := Vector2.from_angle(randf() * 2 * PI)
	
	
	
	character.position = Vector3(pos.x * SPAWN_RANDOM * randf(), 0, pos.y * SPAWN_RANDOM * randf())
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
func update(count_u):
	
	parent_players.text = "Players: " + str(count_u) + "/4"




#cant sent signal direct to rpc func
#need second func
func _area_send(id):
	#print("id")
	rpc("_area_send_info", id)
	
	if is_multiplayer_authority():
		game_ui.visible = true
	


@rpc ("any_peer","call_local")
func _area_send_info(id):
	#Works
	if id > 100 or id == 1:
		var label_test = Label.new()
		label_test.text =str(count) + ": " + str(PlayerManager.Players[id].name)
		label_test.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		table.add_child(label_test)
		count += 1
	
	


