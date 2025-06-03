extends Node3D

@export var MPplayer: PackedScene
@onready var player: CharacterBody3D = $"1"

#@onready var mp_sync: MultiplayerSynchronizer = $MPSync

func _ready() -> void:
	if global.isMP and multiplayer.is_server():
		print("Server: Loaded the world")
		
		if global.Players.size() < global.PlayerCount:
			global.Players.resize(global.PlayerCount)
		global.Players.insert(global.PlayerCount, {"UID" = 0, "Name" = 0})
		print("player Connected: " + str(global.PlayerCount))
		player.name = str(1)
		#mp_sync.set_multiplayer_authority(1)
		
		multiplayer.peer_connected.connect(PeerCon)
		multiplayer.peer_disconnected.connect(PeerDiscon)
	elif global.isMP:
		print("Player " + str(global.PlayerCount) + ": Loaded the world")
		
		player.name = str(global.PlayerCount)
		player.position = Vector3(2,2,2)
		#mp_sync.set_multiplayer_authority(multiplayer.get_remote_sender_id())
		
		var curPlayer = MPplayer.instantiate()
		curPlayer.name = str(1)
		#curPlayer.find_child("PMP_sync", true, false).set_multiplayer_authority(1)
		add_child(curPlayer)
		
		if global.PlayerCount > 2:
			for i in global.PlayerCount-1:
				curPlayer = MPplayer.instantiate()
				curPlayer.name = str(i+2)
				#curPlayer.find_child("PMP_sync", true, false).set_multiplayer_authority(1)
				add_child(curPlayer)
		multiplayer.server_disconnected.connect(Kicked)
	else:
		player.name = str(1)
		
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
	curPlayer.position = Vector3(2,2,2)
	#curPlayer.find_child("PMP_sync", true, false).set_multiplayer_authority(peer_ID)
	add_child(curPlayer)
		
func PeerDiscon(peer_ID:int):
	#Peer Disconnected
	print("peer disconnected: " + str(peer_ID))
	print("player disconnected: " + str(global.PlayerCount))
	
	var curPlayer = get_tree().root.find_child(str(global.PlayerCount), true, false)
	global.Players.remove_at(global.PlayerCount)
	print(curPlayer.name)
	curPlayer.queue_free()
	if global.PlayerCount >= 0:
		global.Players.resize(global.PlayerCount)
		global.PlayerCount -= 1

func Kicked():
	global.isMP = false
	global.multiplayer.multiplayer_peer = null
	global.ClearComs()
	global.ingame = false
	global.ChangeLV("res://main_menu.tscn")
