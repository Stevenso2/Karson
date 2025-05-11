extends Node3D

@onready var main_menu: Control = $MainMenu
@onready var mp_menu: Control = $MPMenu

@onready var sp: Button = $MainMenu/SP
@onready var mp: Button = $MainMenu/MP
@onready var conf: Button = $MainMenu/Conf

@onready var host: Button = $MPMenu/Host
@onready var join: Button = $MPMenu/Join

@onready var responce_timeout: Timer = $"Responce Timeout"

func _ready() -> void:
	responce_timeout.timeout.connect(ExitMP)

func _process(_delta: float) -> void:
	if sp.button_pressed:
		global.ingame = true
		get_tree().change_scene_to_file("res://assets/World.tscn")
	if mp.button_pressed:
		main_menu.hide()
		mp_menu.show()
		
	if host.button_pressed:
		global.ingame = true
		global.MPInit(true)
		get_tree().change_scene_to_file("res://assets/World.tscn")
		
	if join.button_pressed:
		global.MPCheckResponse = true
		responce_timeout.start(0.5)
		global.ingame = true
		var data = JSON.stringify("GET_SRV").to_ascii_buffer()
		global.broadcast.put_packet(data)
		global.MPInit(false)
		get_tree().change_scene_to_file("res://assets/World.tscn")
		
func ExitMP():
	global.MPCheckResponse = false
