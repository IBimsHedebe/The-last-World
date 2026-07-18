extends MeshInstance3D
const PLAYER = preload("uid://cwta612wbdxx7")


@export var mapWidth: int = 100
@export var mapDepth: int = 100
@export var heightScale: float = 20.0

var noise: FastNoiseLite

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.02
	
	_generate_world()
	_spawn_player()

func _generate_world() -> void:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in range(mapDepth):
		for x in range(mapWidth):
			var y = noise.get_noise_2d(x,z) * heightScale
			var uv = Vector2(float(x) / mapWidth, float(z) / mapDepth)
			
			var vertexColor = Color.DARK_GREEN
			if y > heightScale * 0.4:
				vertexColor = Color.MEDIUM_SLATE_BLUE.darkened(0.5)
			if y > heightScale * 0.7:
				vertexColor = Color.WHITE
			
			st.set_uv(uv)
			st.set_color(vertexColor)
			st.add_vertex(Vector3(x,y,z))
	
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
	mesh = st.commit()
	
	create_trimesh_collision()

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
	
	var spawn_y = noise.get_noise_2d(spawn_x, spawn_z) * heightScale
	
	player.global_position = Vector3(spawn_x, spawn_y + 5.0, spawn_z)
	
	get_parent().add_child.call_deferred(player)
