extends Node

var TranslationMap = {
	"venso:grass_block" = 0,
	"venso:cobblestone" = 1,
	"venso:dirt" = 2,
	"venso:ice" = 3
}

enum GateType {AND,NOR,XOR}

var current_Block = 0

var pause = false

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
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
