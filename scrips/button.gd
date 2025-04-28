extends StaticBody3D

@onready var contact_collision: CollisionShape3D = $ContactArea/ContactCollision
@onready var move_collision: CollisionShape3D = $ButtonFace/MoveArea/MoveCollision
@onready var button_face: StaticBody3D = $ButtonFace

# Called when the node enters the scene tree for the first time.


func _on_move_area_area_entered(area: Area3D) -> void:
	pass # Replace with function body.
