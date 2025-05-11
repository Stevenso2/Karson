extends Node3D

@export var TestIds: PackedInt32Array
@export var Own_Id: int = 0
@export var Rising_edge = 0
@export var Falling_edge = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.PObj_IDTunnel.connect(PassTime)

func PassTime(id, OnOff):
	for test in TestIds:
		if test == id:
			# Rising_edge if OnOff else Falling_edge sets the timeout to respective edge
			await get_tree().create_timer(Rising_edge if OnOff else Falling_edge).timeout
			global.PObj_IDTunnel.emit(Own_Id, OnOff)
