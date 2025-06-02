extends Node3D
@export var Next_LVL: PackedScene = preload("res://assets/World.tscn")

func _on_area_3d_area_entered(_area: Area3D) -> void:
	call_deferred("Change_LVL", Next_LVL)



func _on_area_3d_body_entered(body: Node3D) -> void:
	call_deferred("Change_LVL", Next_LVL)

func Change_LVL(Next_LVL):
	get_tree().change_scene_to_packed(Next_LVL)
