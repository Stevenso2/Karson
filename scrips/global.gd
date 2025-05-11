extends Node

enum INV {
	ShotGun,
	GraplingGun,
	Void
}

enum GateType {AND,NOR,XOR}

var Packets = { "get" = JSON.stringify("GET_SRV") }

var current_Block: INV = 0 as INV

var pause = false
var slow = false
var ingame = false

const PORT = 25566
var MP
var MPCheckResponse: bool = false
var peer = ENetMultiplayerPeer.new()
var broadcast: PacketPeerUDP = PacketPeerUDP.new()

var DEV = false

signal PObj_IDTunnel(id, OnOff)

func _ready() -> void:
	PObj_IDTunnel.connect(DebugLoging)
	broadcast.set_broadcast_enabled(true)
	broadcast.set_dest_address("255.255.255.255", PORT)
	var ok = broadcast.bind(PORT)
	if ok == OK:
		print("MP search ready")

func DebugLoging(Key, Value):
	if DEV == true:
		print("[DEV] (noslraK) " + str(Key) + "-" + str(Value))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("REMOVE ON FINAL"):
		DEV = !DEV
	
	if pause or not ingame:
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if slow:
			Engine.time_scale = 0.25
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Engine.time_scale = 1
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
func MPInit(IsHosting, ip = ""):
	MP = get_tree().get_multiplayer()
	
	if IsHosting:
		peer.create_server(PORT)
	else:
		var data = broadcast.get_packet().get_string_from_ascii()
		while MPCheckResponse and data == Packets["get"] or " ":
			var packet = broadcast.get_packet().get_string_from_ascii()
			if Packets.find_key(packet):
				data = packet
		print(data)
		if data == Packets["get"]:
			print("No Server found")

		peer.create_client(ip, PORT)
