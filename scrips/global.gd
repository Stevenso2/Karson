extends Node

enum INV {
	ShotGun,
	GraplingGun,
	Void
}

enum GateType {AND,NOR,XOR}

var current_Block: INV = 0 as global.INV

var pause = false
var slow = false

var DEV = false

signal PObj_IDTunnel(id, OnOff)

func _ready() -> void:
	PObj_IDTunnel.connect(DebugLoging)

func DebugLoging(Key, Value):
	if DEV == true:
		print("[DEV] (noslraK) " + str(Key) + "-" + str(Value))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("REMOVE ON FINAL"):
		DEV = !DEV
	
	if pause:
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if slow:
			Engine.time_scale = 0.25
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Engine.time_scale = 1
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
