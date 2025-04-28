extends Control

@onready var selector: Sprite2D = $Selector
@onready var menu: Sprite2D = $Menu
@onready var quit: Button = $Menu/Quit

var offset = 304
var jump_by = 68

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		global.current_Block = 0
	if Input.is_action_just_pressed("2"):
		global.current_Block = 1
	if Input.is_action_just_pressed("3"):
		global.current_Block = 2
	if Input.is_action_just_pressed("4"):
		global.current_Block = 3
	if Input.is_action_just_pressed("5"):
		pass
	if Input.is_action_just_pressed("6"):
		pass
	if Input.is_action_just_pressed("7"):
		pass
	if Input.is_action_just_pressed("8"):
		pass
	if Input.is_action_just_pressed("9"):
		pass
	
	if Input.is_action_just_pressed("SU"):
		global.current_Block += 1
		if global.current_Block >= 3:
			global.current_Block = 0
	if Input.is_action_just_pressed("SD"):
		global.current_Block -= 1
		if global.current_Block <= 0:
			global.current_Block = 3
			
	if global.pause:
		menu.show()
		if quit.button_pressed:
			get_tree().quit()
	else:
		menu.hide()
	
	selector.position.x = offset * jump_by
