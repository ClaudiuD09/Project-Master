extends Control


@onready var message = $VBoxContainer/Message
@onready var send = $VBoxContainer/send
@onready var messages = $VBoxContainer/messages


var number = 0
var nr = 0

var IS_ON_CHAT = false
var msg : String


func _ready():
	Globals.connect("enter_pressed", Callable(self, "_on_send_pressed"))
	Globals.focus_chat = IS_ON_CHAT





func _on_send_pressed():
	rpc("msg_rpc", Globals.usrnm, message.text)
	message.text = ""

@rpc ("any_peer","call_local")
@warning_ignore("shadowed_variable")
func msg_rpc(usrnm,data):
	data = data.strip_edges()
	if data.length()>0:
		messages.text += str(usrnm, ": ",data, "\n")
		messages.scroll_vertical = messages.get_line_height()  #done




#add players messages
func send_data(data):
	rpc("msg_data", data)


@rpc ("any_peer","call_local")
@warning_ignore("shadowed_variable")
func msg_data(data):
	data = data.strip_edges()
	if data.length()>0:
		messages.text += str(data, "\n")
		messages.scroll_vertical = messages.get_line_height() 



#for clean
func clean():
	rpc("clean_chat")


@rpc ("any_peer","call_local")
@warning_ignore("shadowed_variable")
func clean_chat():
	messages.text = ""





#to verify if it is used
func _on_message_focus_entered():
	IS_ON_CHAT = true
	Globals.focus_chat = IS_ON_CHAT


func _on_message_focus_exited():
	IS_ON_CHAT = false
	Globals.focus_chat = IS_ON_CHAT




