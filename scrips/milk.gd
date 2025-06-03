extends Node3D
@export var Next_LVL: PackedScene

func _on_area_3d_area_entered(_area: Area3D) -> void:
	global.ChangeLV(Next_LVL.resource_path)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	global.ChangeLV(Next_LVL.resource_path)
