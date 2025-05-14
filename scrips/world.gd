extends Node3D

@export var MPplayer: PackedScene
@onready var player: CharacterBody3D = $Player
@onready var mp_sync: MultiplayerSynchronizer = $MPSync

func _ready() -> void:
	if global.isMP and global.MP.is_server():
		print("Server: Loaded the world")
		player.name = str(0)
		global.MP.peer_connected.connect(PeerMGR.bind(true))
		global.MP.peer_disconnected.connect(PeerMGR.bind(false))
	elif global.isMP:
		print("Client: Loaded the world")
		
		player.name = str(1)
		for i in global.PlayerCount:
			var curPlayer = MPplayer.instantiate()
			curPlayer.name = str(0)
			add_child(curPlayer)
		global.MP.server_disconnected.connect(Kicked)
	else:
		player.name = str(0)
		
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
	global.isMP = false
	global.MP.multiplayer_peer = null
	global.ClearComs()
	global.ingame = false
	global.ChangeLV("res://main_menu.tscn")
