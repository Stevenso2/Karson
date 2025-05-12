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

var peer = ENetMultiplayerPeer.new()
var Server: String
var directComs = PacketPeerUDP.new()
const PORT = 25566
const SCANPORT = 25567
var MP: MultiplayerAPI

var DEV = false

signal PObj_IDTunnel(id, OnOff)

func _ready() -> void:
	PObj_IDTunnel.connect(DebugLoging)
	directComs.set_broadcast_enabled(true)
	directComs.set_dest_address("255.255.255.255", global.SCANPORT + 1)
	var ok = directComs.bind(global.SCANPORT)
	if ok == OK:
		print("directComs ready")
	else:
		directComs.set_dest_address("255.255.255.255", global.SCANPORT)
		ok = directComs.bind(global.SCANPORT + 1)
		if ok == OK:
			print("directComs2 ready")

func DebugLoging(Key, Value):
	if DEV == true:
		print("[DEV] (noslraK) " + str(Key) + "-" + str(Value))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("REMOVE ON FINAL"):
		DEV = !DEV
	
	if pause:
		Engine.time_scale = 0
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
			
	if MP and MP.is_server():
		if MP.multiplayer_peer.get_available_packet_count() > 0:
			var data = MP.multiplayer_peer.get_packet().get_string_from_ascii()
			print("Server has Recived: " + str(data))
		if directComs.get_available_packet_count() > 0:
			var data = directComs.get_packet().get_string_from_ascii()
			if data == JSON.stringify("GET_SRV"):
				var responce = JSON.stringify(Server, "Server").to_ascii_buffer()
				directComs.put_packet(responce)
				
			
func MPServer():
	MP = get_tree().get_multiplayer()
	var ok = peer.create_server(PORT, 20)
	if ok == OK:
		print("Server avalable")
	MP.multiplayer_peer = peer
	
func MPClient(ip):
	MP = get_tree().get_multiplayer()
	var ok = peer.create_client(ip, PORT)
	if ok == OK:
		print("Client avalable")
	MP.multiplayer_peer = peer
	
