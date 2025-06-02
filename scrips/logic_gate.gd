extends Node3D

@export var TestIds: PackedInt32Array = []
@export var Own_Id: int = 0
@export var Type = global.GateType.AND
var highestVal = 1

var LocalIndex: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.PObj_IDTunnel.connect(Distribute)

func Distribute(id, OnOff):
	for test in TestIds:
		if test == id:
			if id > highestVal: highestVal = id +1
			LocalIndex.resize(highestVal) 
			LocalIndex.set(id, OnOff)
			var ret
			if Type == global.GateType.AND:
				ret = AND()
			if Type == global.GateType.NOR:
				ret = NOR()
			if Type == global.GateType.XOR:
				ret = XOR()
			global.PObj_IDTunnel.emit(Own_Id, ret)

func AND():
	var ON = true
	for test in LocalIndex:
		if test == false:
			ON = false
	return ON

func NOR():
	for test in LocalIndex:
		if test == true:
			# Rising_edge if OnOff else Falling_edge sets the timeout to respective edge
			return false
	return true
	
func XOR():
	var ON = false
	for test in LocalIndex:
		if test == true:
			# Rising_edge if OnOff else Falling_edge sets the timeout to respective edge
			ON = !ON
	return ON
