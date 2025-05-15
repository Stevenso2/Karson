extends Node

enum INV {
	ShotGun,
	GraplingGun,
	Void
}

enum GateType {AND,NOR,XOR}

var current_Block: INV = 0 as INV

var pause = false
var slow = false
var ingame = false
var isMP = false

var peer = ENetMultiplayerPeer.new()
var Server = { "Name" = "", "PCount" = 1 }
var directComs = PacketPeerUDP.new()
const SEERVERPORT = 25566
var PORT: int
const SCANPORT = 25567
var LAN = "255.255.255.255"
var MP: MultiplayerAPI
var Players: Array = [20]
var PlayerCount = 0

signal MPRecive(Callback)
signal MPReciveCompleate()
signal MPSend(MSG: PackedByteArray, ip: String, port: int)
signal MPPacket()

var DEV = false

signal PObj_IDTunnel(id, OnOff)

func _ready() -> void:
	GetFreePort()
	MPRecive.connect(PacketHandler)
	MPSend.connect(PacketSender)
	PObj_IDTunnel.connect(DebugLoging)
	directComs.set_broadcast_enabled(true)

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
			
	if isMP and MP and MP.is_server():
		MPRecive.emit()

func MPServer():
	MP = get_tree().get_multiplayer()
	var ok = peer.create_server(SEERVERPORT, 20)
	if ok == OK:
		print("Server avalable")
	isMP = true
	MP.multiplayer_peer = peer
	
func ServerComs():
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
	MP = get_tree().get_multiplayer()
	var ok = peer.create_client(ip, SEERVERPORT)
	if ok == OK:
		print("Client avalable")
	isMP = true
	MP.multiplayer_peer = peer
	
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
		
		if MP and MP.is_server():
			print("Server has Directly Recived: " + str(MSG))
			if MSG == JSON.stringify("GET_SRV"):
				print("Sending server ident")
				responce = "ServerIdent: " + JSON.stringify(Server)
			if MSG == JSON.stringify("CON_HAN"):
				print("Sending server Player count")
				var Pcount: int = Server.get("PCount")
				responce = "Pcount: " + JSON.stringify(Pcount)
				Server.set("PCount", Pcount + 1)
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
	
	var ok = directComs.bind(port)
	if ok == OK:
		PORT = port
		directComs.close()
		print("Port has been set")
	else: GetFreePort()

func ChangeLV(file):
	get_tree().change_scene_to_file(file)
