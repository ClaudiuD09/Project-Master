extends Control

const player_scene = preload("res://Player_2D/player_2d.tscn")


const PORT = 8060
const DEFAULT_SERVER_IP = "127.0.0.1"

var server_peer: ENetMultiplayerPeer
var client_peer: ENetMultiplayerPeer

#0=Windows
#1=Android
#2=Web
#3=XR


var user_verifing

@onready var user_name = $UI/Network/Net/Name/user_name
@onready var user_show = $UI/Network/Net/Name_label/user_name


@onready var server_ip_address = $UI/Network/Net/Options/Remote
@onready var device_ip_address = $UI/Network/Net/ip_show
@onready var status = $UI/Network/Net/version
@onready var color = $UI/ColorRect
@onready var browser = $UI/Browser_Setup


@onready var status2 = $UI/Network/Net/ip_show2
@onready var version2 = $UI/Network/Net/version2
@onready var leaderboard = $Leaderboard/Control/Table

@onready var game = $Game_Buttons

func _ready():
	$Start_UI.visible = false
	$Leaderboard.visible = false
	game.visible = false
	
	#multiplayer.peer_connected.connect(peer_connected)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	
	
	
	#Device detect method
	match OS.get_name():
		"Windows", "UWP":
			@warning_ignore("int_as_enum_without_cast")
			device_ip_address.text = "Your IP: %s | Your PORT: %s" % [IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1),PORT]
			#ver = "Windows"
			#status.text = "Version: Windows"
			color.color = Color("#7d6340")
			#mod = 0
		"macOS":
			pass
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			@warning_ignore("unused_variable")
			var local_addresses = IP.get_local_addresses()
			for ip in IP.get_local_addresses():
				if ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("192.168."):
					device_ip_address.text = "Your IP: %s | Your PORT: %s" % [ip,PORT]
			
			if device_ip_address.text == "":
				device_ip_address.text = "No connection found"
			
			
			color.color = Color("#7d6340")
			#mod = 0
		"Android":
			@warning_ignore("unused_variable")
			var local_addresses = IP.get_local_addresses()
			
			for ip in IP.get_local_addresses():
				if ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("192.168."):
					device_ip_address.text = "Your IP: %s | Your PORT: %s" % [ip,PORT]
			
			if device_ip_address.text == "":
				device_ip_address.text = "No connection found"
			
			#ver = "Android"
			#status.text = "Version: Android"
			color.color = Color("#43754f")
			#mod = 1
		"iOS":
			pass
		"Web":
			@warning_ignore("int_as_enum_without_cast")
			device_ip_address.text = "Your IP: %s" % IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
			
			#ver = "Web"
			#status.text = "Version: Web"
			color.color = Color("#99513e")
			#mod = 2
	
	
	
	status.text = "Version: " + Globals.ver
	user_show.text = "Random Name: " + Globals.usrnm



func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()



#called only from clients
func connected_to_server():
	print("connected_to_server")
	
	SendPlayerInformation.rpc_id(1, multiplayer.get_unique_id(), Globals.usrnm, Globals.character2D, Globals.character3D, Globals.color_change )
	
	$Loading.visible = false



#called only from clients
func connection_failed():
	print("connection_failed")


#called only from server
func _server_disconnected():
	print("da")
	$UI.visible = true
	$Loading.visible = true
	
	$UI/Network.visible = true
	color.visible = true
	
	$Chat.visible = false
	$Start_UI.visible = false
	$Leaderboard.visible = false



#transfer de informatii
@rpc("any_peer")
@warning_ignore("shadowed_variable_base_class")
func SendPlayerInformation( id , name, char_2d : int, char_3d : int, color_lib ):
	#2D/3D test

	if !PlayerManager.Players.has(id):
		PlayerManager.Players[id] = {
			"id" : id,
			"name" : name,
			"Character_2D" : char_2d,
			#not used
			"Character_3D" : char_3d,
			#for test
			"Movement" : 0,
			"color" : color_lib
		}
	
	if multiplayer.is_server():
		for i in PlayerManager.Players:
			SendPlayerInformation.rpc(i, PlayerManager.Players[i].name, PlayerManager.Players[i].Character_2D, 
			PlayerManager.Players[i].Character_3D, PlayerManager.Players[i].color)





func _on_create_pressed():
	server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	if server_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server")
		return
	multiplayer.multiplayer_peer = server_peer
	
	
	
	user_verifing = user_name.text.strip_edges()
	if user_verifing != "":
		Globals.usrnm = user_verifing
	
	
	
	
	SendPlayerInformation(multiplayer.get_unique_id(),  Globals.usrnm, Globals.character2D, Globals.character3D, Globals.color_change )
	start_game()





func _on_join_pressed():
	Globals.server_ip_address=server_ip_address.text
	
	client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(server_ip_address.text, PORT)
	
	if client_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client")
		return
	
	multiplayer.multiplayer_peer = client_peer
	
	$UI/Network.hide()
	color.hide()
	$Loading/AnimationPlayer.play("load/loading")
	
	
	user_verifing = user_name.text.strip_edges()
	if user_verifing != "":
		Globals.usrnm = user_verifing



func start_game():
	
	$UI/Network.hide()
	color.hide()
	#$Start_UI.visible = true
	$Loading.visible = false
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level.call_deferred(load("res://Maps_2D/main.tscn"))


func start_game_3d():
	
	$Start_UI.visible = false
	
	# Only change level on the server.
	# Clients will instantiate the level via the spawner.
	if multiplayer.is_server():
		change_level_3d.call_deferred(load("res://Maps_3D/main.tscn"))
	



func change_level(scene: PackedScene):
	# Remove old level if any.
	var level = $Level
	for c in level.get_children():
		level.remove_child(c)
		c.queue_free()
	# Add new level.
	level.add_child(scene.instantiate())
	



func change_level_3d(scene: PackedScene):
	
	var level = $Level
	
	
	await get_tree().create_timer(0).timeout
	
	for c in level.get_children():
		#if c.is_in_group("control"):
		level.remove_child(c)
		c.queue_free()
	
	level.add_child(scene.instantiate())
	
	





#inactiv
####################################################################################################
####################################################################################################

#inactiv
func add_player(id):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
	#print("ADD")
	#v.text=v.text + " ADD"


#inactiv
func remove_player(id):
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()


#UPNP METHOD FOR ONLINE MULTIPLAYER - Need upnp router setup on  
func upnp_setup():
	var upnp = UPNP.new()


	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(),\
		"UPNP Invalid Gatevaway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)

	print("Succes! Join Address: %s" % upnp.query_external_address()) 


func _on_create_online_pressed():
	#if mod == 0:
	@warning_ignore("unassigned_variable")
	var peer
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()

####################################################################################################
####################################################################################################





func _on_start_game_pressed():
	
	start_game_3d()
	
	await get_tree().create_timer(0).timeout
	Globals.game_starter = true


func _on_c_1_pressed():
	Globals.character2D = 1
	version2.text = "Character Selected: " + str(Globals.character2D)
	Globals.color_change = Color(0,1,0,1)


func _on_c_2_pressed():
	Globals.character2D = 2
	version2.text = "Character Selected: " + str(Globals.character2D)
	Globals.color_change = Color(1,0,0,1)


func _on_user_name_text_changed(new_text):
	user_verifing = new_text.strip_edges()
	if user_verifing != "":
		user_show.text = "New Name: " + str(user_verifing)
	else:
		user_show.text = "Random Name: " + Globals.usrnm



func _on_restart_pressed():
	start_game_3d()
	game.visible = false
	await get_tree().create_timer(0).timeout


func _on_lobby_pressed():
	start_game()
	game.visible = false
	await get_tree().create_timer(0).timeout
