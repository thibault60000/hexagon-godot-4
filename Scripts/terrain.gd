extends Node3D

@onready var player = $"../Player"
@export var tiles: Array[Tiles] = []

@onready var tiles_count = $"../Interface/Control/TilesCount"
@onready var generate_button = $"../Interface/Control/Generate"

var worldSize = 64
var count = 0 

var tile_scale_offset_y = 0.33
var tile_scale_offset_z = 0.866

func get_tile_by_name(name: String) -> Tiles:
	for tile in tiles:
		if tile.name == name:
			return tile
	return null
	
func _ready(): 
	var water = Tiles.new()
	water.mesh = preload("res://Models/OBJ format/water.obj")
	water.name = "water"
	
	var water_island = Tiles.new()
	water_island.mesh = preload("res://Models/OBJ format/water_island.obj")
	water_island.name = "water_island"
	
	var water_rocks = Tiles.new()
	water_rocks.mesh = preload("res://Models/OBJ format/water_rocks.obj")
	water_rocks.name = "water_rocks"

	var sand = Tiles.new()
	sand.mesh = preload("res://Models/OBJ format/sand.obj")
	sand.name = "sand"
	
	var sand_rocks = Tiles.new()
	sand_rocks.mesh = preload("res://Models/OBJ format/sand_rocks.obj")
	sand_rocks.name = "sand_rocks"
	
	var dirt = Tiles.new()
	dirt.mesh = preload("res://Models/OBJ format/dirt.obj")
	dirt.name = "dirt"
	
	var dirt_lumber = Tiles.new()
	dirt_lumber.mesh = preload("res://Models/OBJ format/dirt_lumber.obj")
	dirt_lumber.name = "dirt_lumber"

	var grass = Tiles.new()
	grass.mesh = preload("res://Models/OBJ format/grass.obj")
	grass.name = "grass"
	
	var grass_forest = Tiles.new()
	grass_forest.mesh = preload("res://Models/OBJ format/grass_forest.obj")
	grass_forest.name = "grass_forest"
	
	var grass_hill = Tiles.new()
	grass_hill.mesh = preload("res://Models/OBJ format/grass_hill.obj")
	grass_hill.name = "grass_hill"
	
	var stone = Tiles.new()
	stone.mesh = preload("res://Models/OBJ format/stone.obj")
	stone.name = "stone"
	
	var stone_rocks = Tiles.new()
	stone_rocks.mesh = preload("res://Models/OBJ format/stone_rocks.obj")
	stone_rocks.name = "stone_rocks"
	
	var stone_mountain = Tiles.new()
	stone_mountain.mesh = preload("res://Models/OBJ format/stone_mountain.obj")
	stone_mountain.name = "stone_mountain"
	

	tiles = [water, water_island, water_rocks, sand, sand_rocks, dirt, dirt_lumber, grass, grass_forest, grass_hill, stone, stone_rocks, stone_mountain]
	
	create_grid()
	fill_grid()
	update_count()
	set_up_camera()
	
	# Connectez le signal 'pressed' du bouton à la fonction '_on_button_pressed'
	generate_button.pressed.connect(self._on_button_pressed)
	generate_button.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_button_pressed():
	count = 0
	# Supprimez tous les enfants de la carte
	for child in self.get_children():
		if child is MeshInstance3D:
			child.queue_free()

	# Relancez la génération de la carte
	create_grid()
	fill_grid()
	update_count()
	
	
func set_up_camera():
	player.transform.origin = Vector3(worldSize/2, player.transform.origin.y, (worldSize/2) * tile_scale_offset_z)

func update_count():
	tiles_count.text = str(count) +  " tuiles instanciées" 

func setupNoisePingPong(noise):
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	noise.fractal_type = 3 # Ping Pong
	noise.seed = randi()
	noise.frequency = 0.025
	noise.fractal_octaves = 5
	noise.fractal_lacunarity = 3.910
	noise.fractal_gain = 1.140
	noise.fractal_weighted_strength = 1.130
	noise.fractal_ping_pong_strength  = 1.9404

func setupNoiseFBm(noise):
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

	noise.seed = randi()
	noise.frequency = 0.05 # Augmenter la fréquence du bruit peut rendre le terrain plus varié, ce qui pourrait réduire la quantité d’eau si votre carte a actuellement de grandes zones plates au niveau de la mer.
	noise.fractal_octaves = 2 # : Augmenter le nombre d’octaves peut ajouter plus de détails au bruit, ce qui pourrait rendre le terrain plus varié et réduire la quantité d’eau.
	noise.fractal_lacunarity = 2.0  # Augmentez la lacunarité pour plus de variété dans les biomes
	noise.fractal_gain = 0.7  # Le gain contrôle le contraste du bruit. Un gain plus élevé peut rendre le terrain plus accidenté, ce qui pourrait également réduire la quantité d’eau.
	noise.fractal_type = 1  # Utilisez le bruit fractal FBm pour un effet plus naturel

func fill_grid():
	pass

func generate_water_types():
	var water_types = []
	for i in range(90):
		water_types.append("water")
	for i in range(8):
		water_types.append("water_rocks")
	for i in range(2):
		water_types.append("water_island")
	return water_types
	
func generate_grass_types():
	var grass_types = []
	for i in range(60):
		grass_types.append("grass")
	for i in range(20):
		grass_types.append("grass_forest")
	for i in range(20):
		grass_types.append("grass_hill")
	return grass_types
		
func generate_sand_types():
	var sand_types = []
	for i in range(70):
		sand_types.append("sand")
	for i in range(30):
		sand_types.append("sand_rocks")
	return sand_types

func generate_dirt_types():
	var dirt_types = []
	for i in range(70):
		dirt_types.append("dirt")
	for i in range(30):
		dirt_types.append("dirt_lumber")
	return dirt_types
	
		
func create_grid(): 
	var noise = FastNoiseLite.new()
	
	setupNoiseFBm(noise)
	
	var offset = 0
	
	for x in range(worldSize):
		offset = 0
		for z in range(worldSize):
			if x % 2 and z % 2:
				if offset == 1:
					offset = 0
				else:
					offset = 1
				
				var noise_2D = noise.get_noise_2d(x, z) # Valeur entre -1 et 1
				var noise_2D_base_10 = round((noise_2D) * 10)
				var height = clamp(noise_2D_base_10, -1 , 10)
				
				var tile_name = "grass"
				
				if height <= 0: 
					var water_types = generate_water_types()
					tile_name = water_types[randi() % water_types.size()]
					height = 0
		
				if height > 0 and height < 2:
					var sand_types = generate_sand_types()
					tile_name = sand_types[randi() % sand_types.size()]
					height = 0.25
					
				if height >=2 and height <3:
					var grass_types = generate_grass_types()
					tile_name = grass_types[randi() % grass_types.size()]
					height = 0.5
					
				if height >= 3 and height < 4:
					var dirt_lumber = generate_dirt_types()
					tile_name = dirt_lumber[randi() % dirt_lumber.size()]
					height = 0.75
					
				if height >= 4 and height <5:
					tile_name = "stone"
					height = 1
					
				if height >= 5 and height < 6:
					tile_name = "stone_rocks"
					height = 1.25
					
				if height >= 6:
					tile_name = "stone_mountain"
					height = 1.50
				
			
				var mesh_instance = MeshInstance3D.new()
				mesh_instance.mesh = get_tile_by_name(tile_name).mesh
				mesh_instance.transform.origin = Vector3(x + offset, height * tile_scale_offset_y, z * tile_scale_offset_z)
				mesh_instance.scale = Vector3(1, 1, 1)
				
				var random_y_rotation = randi() % 6 * 60 # Génère un multiple aléatoire de 60 entre 0 et 300
				mesh_instance.rotation_degrees.y = random_y_rotation # Applique la rotation à l'objet sur l'axe Y
				
# 				Créez une nouvelle instance de StaticBody3D pour contenir le CollisionShape3D
				var static_body = StaticBody3D.new()

				# Créez une nouvelle instance de CollisionShape3D
				var collision_shape = CollisionShape3D.new()

				# Créez une nouvelle instance de ConvexPolygonShape3D
				var convex_shape = ConvexPolygonShape3D.new()

				# Définissez les points du ConvexPolygonShape3D pour correspondre à ceux de votre mesh
				convex_shape.points = mesh_instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]

				# Définissez la forme du CollisionShape3D sur le ConvexPolygonShape3D
				collision_shape.shape = convex_shape

				# Ajoutez le MeshInstance3D et le CollisionShape3D comme enfants du StaticBody3D
				mesh_instance.add_child(static_body)
				static_body.add_child(collision_shape)

				self.add_child(mesh_instance)
				count += 1
