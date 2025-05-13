extends Node3D

@export var MPplayer: PackedScene

func _ready() -> void:
	if global.MP.is_server():
		print("Server: Loaded the world")
		global.MP.peer_connected.connect(PeerMGR.bind(true))
		global.MP.peer_disconnected.connect(PeerMGR.bind(false))
	else:
		print("Client: Loaded the world")
		global.MP.server_disconnected.connect(Kicked)
		
func _process(_delta: float) -> void:
	pass


func PeerMGR(CON_DISCON:bool, peer_ID:int):
	if CON_DISCON:
		#Peer Connected
		print("peer connected: " + str(peer_ID))
		global.Players.insert(peer_ID, {"Name" = peer_ID})
		var curPlayer = MPplayer.instantiate()
		curPlayer.name = str(peer_ID)
		add_child(curPlayer)
	else:
		#Peer Disconnected
		print("peer disconnected: " + str(peer_ID))

func Kicked():
	global.MP.multiplayer_peer = null
	global.ClearComs()
	global.ingame = false
	global.ChangeLV("res://main_menu.tscn")
