extends Node3D

@export var MPplayer: PackedScene
@onready var player: CharacterBody3D = $"0"

#@onready var mp_sync: MultiplayerSynchronizer = $MPSync

func _ready() -> void:
	if global.isMP and global.MP.is_server():
		print("Server: Loaded the world")
		
		if global.Players.size() < global.PlayerCount:
			global.Players.resize(global.PlayerCount)
		global.Players.insert(global.PlayerCount, {"UID" = 0, "Name" = 0})
		print("player Connected: " + str(global.PlayerCount))
		player.name = str(0)
		
		global.MP.peer_connected.connect(PeerCon)
		global.MP.peer_disconnected.connect(PeerDiscon)
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


func PeerCon(peer_ID:int):
	#Peer Connected
	print("peer connected: " + str(peer_ID))
	if global.Players.size() < global.PlayerCount:
		global.Players.resize(global.PlayerCount)
	global.Players.insert(global.PlayerCount, {"UID" = peer_ID, "Name" = peer_ID})
	print("player Connected: " + str(global.PlayerCount))
	var curPlayer = MPplayer.instantiate()
	curPlayer.name = str(global.PlayerCount)
	add_child(curPlayer)
		
func PeerDiscon(peer_ID:int):
	#Peer Disconnected
	print("peer disconnected: " + str(peer_ID))
	print("player disconnected: " + str(global.PlayerCount))
	
	var curPlayer = get_tree().root.find_child(str(global.PlayerCount), true, false)
	global.Players.remove_at(global.PlayerCount)
	curPlayer.Respawn()
	curPlayer.queue_free()
	if global.PlayerCount >= 0:
		global.Players.resize(global.PlayerCount)
		global.PlayerCount -= 1

func Kicked():
	global.isMP = false
	global.MP.multiplayer_peer = null
	global.ClearComs()
	global.ingame = false
	global.ChangeLV("res://main_menu.tscn")
