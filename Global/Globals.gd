extends Node
#Local Library


var mode = 5 #test
var vers = ""
var server_ip_address 
var game_starter = false

var usrnm : String

signal enter_pressed
signal area_signal


var color_change : Color = Color(1,1,1,1)
var focus_chat



var character2D : int = 0
var character3D : int = 0

var number_players : int = 0


#0=Windows
#1=Android
#2=Linux
#3=XR
#4=Web

var xr_interface: XRInterface

var mod
var ver = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	match OS.get_name():
		"Windows", "UWP":
			ver = "Windows"
			mode = 0
		"macOS":
			pass
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			ver = "Linux"
			mode = 2
		"Android":
			ver = "Android"
			mode = 1
		"iOS":
			pass
		"Web":
			ver = "Web"
			mode = 4
	
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		Globals.mode = 3
		Globals.ver = "XR"
	
	
	var rng = RandomNumberGenerator.new()
	@warning_ignore("narrowing_conversion")
	var _random:int = rng.randf_range(10, 90)
	Globals.usrnm = "User_" + str(_random)
	
	#verify
	print(Globals.usrnm)
	print("Version:",ver)
	print("Mode:",mode)
	





