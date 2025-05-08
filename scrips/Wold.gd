extends Node3D

@export var GenChunk = false
@export var ChunkPos = Vector3(0,0,0)
@export var Seed = randi()

@onready var Blockmap = $"Block map"

var pregen = []
var perlinNoise: FastNoiseLite

func makePerlin():
	perlinNoise = FastNoiseLite.new()
	perlinNoise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN
	perlinNoise.seed = Seed

func fill_pregen():
	for x in range(-10, 11):
		for z in range(-10, 11):
			pregen.append(Vector3(x, -1, z))
	
func render():
	if GenChunk == true: 
		for chunk in pregen:
			GenarateChunk(chunk)
			await get_tree().create_timer(0).timeout
		GenChunk = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		global.pause = false

func GenarateChunk(chunkpos: Vector3):
	var CBlock_PosX = chunkpos.x * 16 + 1
	var CBlock_PosY = chunkpos.y * 16 + 1
	var CBlock_PosZ = chunkpos.z * 16 + 1
	
	for Cx in 16:
		for Cy in 16:
			for Cz in 16:
				var x = CBlock_PosX + Cx
				var y = CBlock_PosY + Cy
				var z = CBlock_PosZ + Cz
				
				var NoisePos = perlinNoise.get_noise_2d(x, z) * 10 - 5
				
				var Blocktype = global.TranslationMap.get("venso:cobblestone")
				if (y >= NoisePos -5):
					Blocktype = global.TranslationMap.get("venso:dirt")
				if (y >= NoisePos):
					Blocktype = global.TranslationMap.get("venso:grass_block")
				if (y > NoisePos +1):
					continue
				global.call_deferred("setBlock", Blockmap, Vector3(x, y, z), Blocktype)

func _ready() -> void:
	global.killWorld.connect(end)
	get_tree().set_auto_accept_quit(false)
	makePerlin()
	fill_pregen()
	var cells = Blockmap.get_used_cells()
	for cell in cells:
		global.setBlock(Blockmap, cell, Blockmap.get_cell_item(cell))
	global.intersectSpaceState = Blockmap.get_world_3d().direct_space_state
	var worldrenderthread = Thread.new()
	worldrenderthread.start(render)
	worldrenderthread.wait_to_finish()
	#var eventThread = Thread.new()
	#eventThread.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func end():
	var killThread = Thread.new()
	killThread.start(kill)
	killThread.wait_to_finish()
	
func kill():
	pregen = []
	var cells = Blockmap.get_used_cells()
	for cell: Vector3 in cells:
		global.interact_ray(Blockmap, cell, 0, 1, 0)
		
	Blockmap.queue_free()
	
