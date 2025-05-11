extends Node3D
@onready var door: StaticBody3D = $Door

@export var TestIDs: PackedInt32Array
@export var OpenHeight = 3
@export var CloseHeight = 1

var isOpen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.PObj_IDTunnel.connect(Button_detect)

func Button_detect(id, OnOff):
	#print("button detected: " + str(id))
	for test in TestIDs:
		if test == id:
			isOpen = OnOff

func _physics_process(delta: float) -> void:
	#Move the door
	if isOpen && door.position.y <= OpenHeight:
		door.position.y += 4 * delta
	if !isOpen && door.position.y >= CloseHeight:
		door.position.y -= 4 * delta
		
	#Limit the positions
	if door.position.y >= OpenHeight:
		door.position.y = OpenHeight
	if door.position.y <= CloseHeight:
		door.position.y = CloseHeight
