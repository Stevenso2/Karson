extends StaticBody3D
@onready var animation_player: AnimationPlayer = $"AnimationPlayer"

@export var id: int = 0

func Intercat():
	animation_player.play("intercat")
	await get_tree().create_timer(0.1).timeout
	global.PObj_IDTunnel.emit(id, true)
	await get_tree().create_timer(0.1).timeout
	global.PObj_IDTunnel.emit(id, false)
