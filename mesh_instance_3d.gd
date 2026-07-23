extends MeshInstance3D
const PLAYER = preload("uid://cwta612wbdxx7")
const MONSTER = preload("res://bulwark-shell.tscn")

@export var terrainCurve: Curve

@export var mapWidth: int = 500
@export var mapDepth: int = 500
@export var heightScale: float = 200.0

var heightNoise: FastNoiseLite
var riverNoise: Array

signal generationProgress(percent: float)
signal generationFinished

func _ready() -> void:
	heightNoise = FastNoiseLite.new()
	heightNoise.seed = randi()
	heightNoise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	heightNoise.frequency = 0.01
	heightNoise.fractal_weighted_strength = 1.2
	
	WorkerThreadPool.add_task(_thread_generate_world)

func _finalize_mesh(st: SurfaceTool):
	mesh = st.commit()
	create_trimesh_collision()
	_apply_vertex_material()
	_spawn_player()
	_spawn_monster()
	
	generationFinished.emit()

func carve_rivers(height_map: Array, width: int, depth: int) -> Array:
	var river_noise = FastNoiseLite.new()
	river_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	river_noise.frequency = 0.005
	
	var river_width_threshold: float = 0.15
	var river_depth_power: float = 2.0
	var carve_strength: float = 0.4
	
	for x in range(width):
		for z in range(depth):
			var raw_river_value: float = river_noise.get_noise_2d(float(x), float(z))
			
			raw_river_value = (raw_river_value + 1.0) / 2.0 
			
			if raw_river_value < river_width_threshold:
				var river_gradient: float = 1.0 - (raw_river_value / river_width_threshold)
				var river_profile: float = pow(river_gradient, river_depth_power)
				var current_height: float = height_map[x][z]
				var target_river_floor: float = current_height - carve_strength
				
				height_map[x][z] = lerp(current_height, target_river_floor, river_profile)
				height_map[x][z] = maxf(height_map[x][z], -1.0)
	
	return height_map

func _thread_generate_world() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var totalVertices = mapDepth * mapWidth
	var currentVertex = 0
	
	for z in range(mapDepth):
		for x in range(mapWidth):
			var hVal = heightNoise.get_noise_2d(x,z)
			var normalizedH = clampf((hVal + 1.0) / 2, 0.0, 1.0)
			
			var layeredH = terrainCurve.sample(normalizedH)
			layeredH = clampf(layeredH, 0.0, 1.0)
			
			hVal = (layeredH * 2.0) - 1.0
			
			var rVal = carve_rivers(riverNoise, 10, 5)[x]
			
			var y = hVal * heightScale - rVal
			var uv = Vector2(float(x) / mapWidth, float(z) / mapDepth)
			
			var vertexColor = Color.DARK_GREEN
			if hVal > 0.8:
				vertexColor = Color.WHITE
			elif hVal > 0.6:
				vertexColor = Color.DARK_SLATE_GRAY
		
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

func _spawn_monster():
	if not MONSTER:
		print("Kein Monster")
		return
	
	var monster = MONSTER.instantiate()
	
	var spawn_x = mapWidth / 2.0
	var spawn_z = mapDepth / 2.0 + 20
	var spawn_y = heightNoise.get_noise_2d(spawn_x, spawn_z) * heightScale
	
	monster.global_position = Vector3(spawn_x, spawn_y + 5.0, spawn_z)
	get_parent().add_child.call_deferred(monster)
