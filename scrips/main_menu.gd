extends Node3D

@onready var main_menu: Control = $MainMenu
@onready var mp_menu: Control = $MPMenu

@onready var sp: Button = $MainMenu/SP
@onready var mp: Button = $MainMenu/MP
@onready var conf: Button = $MainMenu/Conf
@onready var quit: Button = $MainMenu/Quit

@onready var host: Button = $MPMenu/Host
@onready var join: Button = $MPMenu/Join
@onready var MPreturn: Button = $MPMenu/MPReturn

func _ready() -> void:
	request_timer.timeout.connect(getServs)
		
@onready var server_search: Control = $"Server Search"
@onready var request_timer: Timer = $"RequestTimer"
@onready var item_list: ItemList = $"Server Search/ItemList"
@onready var search_return: Button = $"Server Search/SearchReturn"

@onready var server_create: Control = $"Server Create"
@onready var create_return: Button = $"Server Create/CreateReturn"
@onready var create_server: Button = $"Server Create/CreateServer"
@onready var server_name: LineEdit = $"Server Create/Server Name"

@onready var connect_server: Button = $"Server Search/ConnectServer"

var Servers = []
var NewGetSRVPackets = []
var serv: Dictionary

func _process(_delta: float) -> void:
	if sp.button_pressed:
		global.ingame = true
		get_tree().change_scene_to_file("res://assets/World.tscn")
	if mp.button_pressed:
		main_menu.hide()
		global.GetFreePort()
		mp_menu.show()
		
	if host.button_pressed:
		mp_menu.hide()
		server_create.show()
		
	if create_return.button_pressed:
		server_create.hide()
		mp_menu.show()
		
	if join.button_pressed:
		mp_menu.hide()
		server_search.show()
		global.ClientComs()
		global.MPReciveCompleate.connect(ListServer)
		request_timer.start(5)
		getServs()
		
	if create_server.button_pressed:
		if server_name.text.length() > 0:
			global.ServerComs()
			global.ingame = true
			global.Server.set("Name", server_name.text)
			global.MPServer()
			global.ChangeLV("res://assets/World.tscn")
		
	if quit.button_pressed:
		get_tree().quit()
		
	if MPreturn.button_pressed:
		request_timer.stop()
		mp_menu.hide()
		main_menu.show()
		
	if search_return.button_pressed:
		server_search.hide()
		mp_menu.show()
		global.MPReciveCompleate.disconnect(ListServer)
		
	if item_list.is_anything_selected():
		connect_server.show()
	else:
		connect_server.hide()
		
	if item_list.is_anything_selected() && connect_server.button_pressed:
		var Items = item_list.get_selected_items()
		if Items.size() == 1:
			server_search.hide()
			serv = Servers.get(Items.get(0))
			request_timer.stop()
			global.MPReciveCompleate.disconnect(ListServer)
			
			var request = JSON.stringify("CON_HAN")
			global.MPSend.emit(request, serv.get("IP"), global.SCANPORT)
			global.isMP = true
			global.MPRecive.emit(PacketParse, true)
			get_tree().create_timer(10).timeout.connect(func(): global.MPReciveCompleate.emit())
			await global.MPReciveCompleate
			if global.PlayerCount <= 1:
				global.isMP = false
				item_list.deselect_all()
				global.MPReciveCompleate.connect(ListServer)
				request_timer.start(5)
				getServs()
				server_search.show()
				return
			global.ClearComs()
			global.MPClient(serv.get("IP"))
			item_list.deselect_all()
			multiplayer.connected_to_server.connect(Connected)
			multiplayer.connection_failed.connect(ConectionFailed)
			
func Connected():
	print("Client Has Connected")
	global.ingame = true
	global.Server.set("Name", serv.get("Name"))
	global.ChangeLV("res://assets/World.tscn")
	
func ConectionFailed():
	print("Client Has Failed to Connect")
	global.isMP = false
	multiplayer.multiplayer_peer = null
	global.ClientComs()
	global.MPReciveCompleate.connect(ListServer)
	request_timer.start(5)
	getServs()
	
	
func getServs():
	if not request_timer.is_stopped():
		request_timer.start(5)
	print("getting Servers")
	var request = JSON.stringify("GET_SRV")
	global.MPSend.emit(request, global.LAN, global.SCANPORT)
	global.MPRecive.emit(PacketParse, true)
	
func PacketParse(MSG: String, ip: String, _port: int):
	if MSG.begins_with("ServerIdent: "):
		print("got server ident")
		var NewServer: Dictionary = JSON.parse_string(MSG.erase(0, "ServerIdent: ".length()))
		ListGetSRVPackets(NewServer.get("Name"), ip)
	if MSG.begins_with("Pcount: "):
		print("got server Player count")
		ConHANPacket(JSON.parse_string(MSG.erase(0, "Pcount: ".length())))
	
func ConHANPacket(Pcount: int):
	if global.PlayerCount <= 1:
		print("Set PCount: " + str(Pcount + 1))
		global.PlayerCount = Pcount + 1
	
func ListGetSRVPackets(Name: String, ip: String):
	var LocalServer = { "Name" = Name, "IP" = ip }
	NewGetSRVPackets.append(LocalServer)
	for Server:Dictionary in Servers:
		if Server.get("IP") == ip:
			return
	Servers.append(LocalServer)
	item_list.add_item(Name)

func ListServer():
	await get_tree().create_timer(0.5).timeout
	if not request_timer.is_stopped():
		request_timer.start(5)
	for Server:Dictionary in Servers:
		if not NewGetSRVPackets.has(Server):
			item_list.remove_item(Servers.find(Server))
			Servers.remove_at(Servers.find(Server))
	NewGetSRVPackets.clear()
