extends StaticBody3D

@onready var button_face: StaticBody3D = $ButtonFace

@export var id: int = 0
@export var ButtonSpeed: float = 0.8

var move = false

func _physics_process(delta: float) -> void:
	if move:
		if button_face.position.y <= 0.375 && button_face.position.y > 0.15:
			button_face.position.y -= ButtonSpeed * delta
	else:
		if button_face.position.y < 0.375 && button_face.position.y >= 0.15:
			button_face.position.y += ButtonSpeed * delta
	
	if button_face.position.y > 0.375:
		button_face.position.y = 0.375
		
	if button_face.position.y < 0.15:
		button_face.position.y = 0.15



func move_area_entered(_body: Node3D) -> void:
	move = true
func move_area_exited(_body: Node3D) -> void:
	move = false
	
func contact_area_entered(body: Node3D) -> void:
	if body.is_in_group("PObj"):
		global.PObj_IDTunnel.emit(id, true)
func contact_area_exited(body: Node3D) -> void:
	if body.is_in_group("PObj"):
		global.PObj_IDTunnel.emit(id, false)
