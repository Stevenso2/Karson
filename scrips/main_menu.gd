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

var Servers = []
var NewPackets = []

func _process(_delta: float) -> void:
	if sp.button_pressed:
		global.ingame = true
		get_tree().change_scene_to_file("res://assets/World.tscn")
	if mp.button_pressed:
		main_menu.hide()
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
		if server_name.text.length() >= 0:
			global.ServerComs()
			global.ingame = true
			global.Server.set("Name", server_name.text)
			global.MPServer()
			get_tree().change_scene_to_file("res://assets/World.tscn")
		
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
	
	
func getServs():
	#if not request_timer.is_stopped():
	#	request_timer.start(5)
	print("getting Servers")
	var request = JSON.stringify("GET_SRV")
	global.MPSend.emit(request, global.LAN, global.SCANPORT)
	global.MPRecive.emit(ListPackets)

func ListPackets(Name: String, ip: String, _port: int):
	var LocalServer = { "Name" = Name, "IP" = ip }
	NewPackets.append(LocalServer)
	for Server:Dictionary in Servers:
		if Server.get("IP") == ip:
			return
	Servers.append(LocalServer)
	item_list.add_item(Name)

func ListServer():
	for Server:Dictionary in Servers:
		if not NewPackets.has(Server):
			item_list.remove_item(Servers.find(Server))
			Servers.remove_at(Servers.find(Server))
	NewPackets.clear()
