extends Node

enum INV {
	ShotGun,
	GraplingGun,
	Void
}

enum GateType {AND,NOR,XOR}

var current_Block: INV = 0 as INV
var transition: AnimationPlayer # used to make the BodyAnimationPlayer callable on every script

var pause = false
var slow = false
var ingame = false
var isMP = false

var peer = ENetMultiplayerPeer.new()
var Server = { "Name" = "" }
var directComs = PacketPeerUDP.new()
const SEERVERPORT = 25566
var PORT: int
const SCANPORT = 25567
var LAN = "255.255.255.255"
var Players: Array = []
var PlayerCount = 1
var is_server = false

signal MPRecive(Callback)
signal MPReciveCompleate()
signal MPSend(MSG: PackedByteArray, ip: String, port: int)
signal MPPacket()

var DEV = false

signal PObj_IDTunnel(id, OnOff)

func _ready() -> void:
	MPRecive.connect(PacketHandler)
	MPSend.connect(PacketSender)
	PObj_IDTunnel.connect(DebugLoging)

func DebugLoging(Key, Value):
	if DEV == true:
		print("[DEV] (noslraK) " + str(Key) + "-" + str(Value))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("REMOVE ON FINAL"):
		DEV = !DEV
		
	if isMP and directComs and directComs.get_available_packet_count() > 0:
		MPPacket.emit()
	
	if pause:
		Engine.time_scale = 0.00001
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif not ingame:
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if slow:
			Engine.time_scale = 0.25
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Engine.time_scale = 1
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if isMP and is_server:
		MPRecive.emit()

func MPServer():
	peer.close()
	var ok = peer.create_server(SEERVERPORT, 20)
	if ok == OK:
		print("Server avalable")
	isMP = true
	is_server = true
	multiplayer.multiplayer_peer = peer
	
func ServerComs():
	directComs = PacketPeerUDP.new()
	var ok = directComs.bind(SCANPORT)
	if ok == OK:
		print("directComs Server ready")
	
func ClientComs():
	#var ok = directComs.bind(PORT)
	#if ok == OK:
	print("directComs Client ready")
		
func ClearComs():
	directComs = null
	
func MPClient(ip):
	print("setting Client MP")
	peer.close()
	var ok = peer.create_client(ip, SEERVERPORT)
	if ok == OK:
		print("Client avalable")
	isMP = true
	multiplayer.multiplayer_peer = peer
	print("Client MP now has a peer")
	
func PacketHandler(callback: Callable = print, usecallback: bool = false):
	if directComs.get_available_packet_count() == 0:
		#print(str(usecallback) + "awaiting packet count")
		await MPPacket
	if not directComs:
		return
	for i in directComs.get_available_packet_count():
		var data = directComs.get_packet()
		var ip = directComs.get_packet_ip()
		var port = directComs.get_packet_port()
		
		var responce
		var MSG = data.get_string_from_ascii()
		
		if isMP and is_server:
			print("Server has Directly Recived: " + str(MSG))
			if MSG == JSON.stringify("GET_SRV"):
				print("Sending server ident")
				responce = "ServerIdent: " + JSON.stringify(Server)
			if MSG == JSON.stringify("CON_HAN"):
				print("Sending server Player count")
				var Pcount: int = PlayerCount
				responce = "Pcount: " + JSON.stringify(Pcount)
				PlayerCount += 1
		else:
			print("Client has Directly Recived: " + str(MSG))
			responce = MSG
		
		
		if responce != null:
			if usecallback:
				callback.call(responce, ip, port)
			else:
				MPSend.emit(responce, ip, port)
	MPReciveCompleate.emit()
	
func PacketSender(MSG: String, ip: String, port: int):
	var data = MSG.to_ascii_buffer()
	directComs.set_dest_address(ip, port)
	directComs.put_packet(data)
	
func GetFreePort():
	var port = (randi() % (65535-49152)) + 49152
	directComs = PacketPeerUDP.new()
	directComs.set_broadcast_enabled(true)
	
	var ok = directComs.bind(port)
	if ok == OK:
		PORT = port
		directComs.close()
		print("Port has been set")
	else: GetFreePort()

func ChangeLV(file):
	get_tree().change_scene_to_file(file)
