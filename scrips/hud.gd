extends Control

@onready var selector: Sprite2D = $Selector
@onready var menu: Sprite2D = $Menu
@onready var quit: Button = $Menu/Quit

@onready var shot_gun: RichTextLabel = $ShotGun
@onready var grappling_gun: RichTextLabel = $GrapplingGun

var offset = 471.5
var jump_by = 68

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		global.current_Block = 0 as global.INV
	if Input.is_action_just_pressed("2"):
		global.current_Block = 1 as global.INV
	if Input.is_action_just_pressed("3"):
		global.current_Block = 2 as global.INV
	
	if Input.is_action_just_pressed("SD"):
		global.current_Block = (global.current_Block as int + 1) as global.INV
		if global.current_Block > 2:
			global.current_Block = 0 as global.INV
	if Input.is_action_just_pressed("SU"):
		global.current_Block = (global.current_Block as int - 1) as global.INV
		if global.current_Block < 0:
			global.current_Block = 2 as global.INV
#	somehow fix the scroll problem i am a dum dum to fix it
	if global.pause:
		menu.show()
		if quit.button_pressed || Input.is_action_just_pressed("Enter"):
			global.ingame = false
			global.Server.set("Name", "")
			global.PlayerCount = 1
			global.Players = []
			global.isMP = false
			multiplayer.multiplayer_peer = null
			global.is_server = false
			get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		menu.hide()
	
	selector.position.y = offset + global.current_Block * jump_by
