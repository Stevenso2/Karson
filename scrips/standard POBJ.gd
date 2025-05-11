extends Node3D

var RESPAWN_POS: Vector3
var RESPAWN_ROT: Vector3

func _ready() -> void:
	RESPAWN_POS = position
	RESPAWN_ROT = rotation

func Respawn():
	position = RESPAWN_POS
	rotation = RESPAWN_ROT
