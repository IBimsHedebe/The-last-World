extends MeshInstance3D
const PLAYER = preload("uid://cwta612wbdxx7")

@export var terrainCurve: Curve

@export var mapWidth: int = 1000
@export var mapDepth: int = 1000
@export var heightScale: float = 150.0

var heightNoise: FastNoiseLite
var moisterNoise: FastNoiseLite

signal generationProgress(percent: float)
signal generationFinished

func _ready() -> void:
	heightNoise = FastNoiseLite.new()
	heightNoise.seed = randi()
	heightNoise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	heightNoise.frequency = 0.01
	heightNoise.fractal_octaves = 4
	
	moisterNoise = FastNoiseLite.new()
	moisterNoise.seed = randi()
	moisterNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	moisterNoise.frequency = 0.1
	
	WorkerThreadPool.add_task(_thread_generate_world)

func _thread_generate_world() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var totalVertices = mapDepth * mapWidth
	var currentVertex = 0
	
	for z in range(mapDepth):
		for x in range(mapWidth):
			var hVal = heightNoise.get_noise_2d(x,z)
			var mVal = moisterNoise.get_noise_2d(x,z)
			
			var normalizedH = (hVal + 1.0) / 2
			var layeredH = normalizedH
			if terrainCurve:
				layeredH = terrainCurve.sample(normalizedH)
			
			hVal = (layeredH * 2.0) - 1.0
			
			var y = hVal * heightScale
			var uv = Vector2(float(x) / mapWidth, float(z) / mapDepth)
			
			var vertexColor = Color.DARK_GREEN
			if hVal > 0.8:
				vertexColor = Color.WHITE
			elif hVal > 0.6:
				vertexColor = Color.DARK_SLATE_GRAY
			else:
				if mVal > -0.2:
					vertexColor = Color.PALE_GOLDENROD
				elif  mVal > 0.2:
					vertexColor = Color.MEDIUM_SEA_GREEN
				else:
					vertexColor = Color.YELLOW_GREEN
		
			st.set_uv(uv)
			st.set_color(vertexColor)
			st.add_vertex(Vector3(x,y,z))
			
			currentVertex += 1
			if currentVertex % 500 == 0:
				generationProgress.emit.call_deferred(float(currentVertex) / totalVertices * 100.0)
	
	for z in range(mapDepth - 1):
		for x in range(mapWidth - 1):
			var v0 = x + z * mapWidth
			var v1 = (x + 1) + z * mapWidth
			var v2 = x + (z + 1) * mapWidth
			var v3 = (x + 1) + (z + 1) * mapWidth
			
			st.add_index(v0)
			st.add_index(v1)
			st.add_index(v2)
			
			st.add_index(v1)
			st.add_index(v3)
			st.add_index(v2)
	
	st.generate_normals()
	
	call_deferred("_finalize_mesh", st)

func _finalize_mesh(st: SurfaceTool):
	mesh = st.commit()
	create_trimesh_collision()
	_apply_vertex_material()
	_spawn_player()
	
	generationFinished.emit()

func _apply_vertex_material():
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.roughness = 0.8
	material_override = mat

func _spawn_player():
	if not PLAYER:
		print("Kein Player")
		return
	
	var player = PLAYER.instantiate()
	
	var spawn_x = mapWidth / 2.0
	var spawn_z = mapDepth / 2.0
	var spawn_y = heightNoise.get_noise_2d(spawn_x, spawn_z) * heightScale
	
	player.global_position = Vector3(spawn_x, spawn_y + 5.0, spawn_z)
	get_parent().add_child.call_deferred(player)
