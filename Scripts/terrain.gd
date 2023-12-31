extends Node

@onready var terrain = $GridMapTiles
@onready var objects = $GridMapObjects

var worldSize = 64

func _ready(): generate()

func setupNoise(noise):
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	
	noise.seed = randi()
	# Plus la fréquence est basse, plus les biomes de la carte (prairies, forêts, lacs, montagnes) seront larges. 
	noise.frequency = 0.08
	# Plus il y a d'octaves, moins les éléments de la carte sont bien séparés.
	noise.fractal_octaves = 2

func generate():
	var noise = FastNoiseLite.new()
	
	setupNoise(noise)
	
	var offset = 0
	
	for x in range(worldSize):
		
		offset = 0
		
		for y in range(worldSize):
			
			if x % 2 and y % 2:
				
				if offset == 1:
					offset = 0
				else:
					offset = 1
				
				# Get noise value for tile
					
				var _noise = round(noise.get_noise_2d(x, y) * 10)
				
				# Terrain tile (color)
				
				var _tile = 0
				if _noise < 0: _tile = 1
				if _noise > 1: _tile = 2
				
				
				set_terrain(Vector3(x + offset, _noise, y), _tile)
				
				# Place objects (randomly)
				
				var _random = randf_range(0, 6)
				
				var _quaternion = Quaternion(Vector3(0, 1, 0), deg_to_rad(randf_range(0, 180)))
				var _randomRotation = objects.get_orthogonal_index_from_basis(Basis(_quaternion))
				
				# 0 = grass
				# 1 = sand
				# 2 = rock
				
				if _tile == 0:
					if  _random < 1:
						# forest
						set_tile(Vector3(x + offset, _noise, y), 2, _randomRotation)

					elif  _random < 2:
						# moutain
						set_tile(Vector3(x + offset, _noise, y), 0, _randomRotation)					


				elif _tile > 1 and _random < 1:
					# house
					set_tile(Vector3(x + offset, _noise, y), 1, _randomRotation)

func set_terrain(_position, _tile):
	terrain.set_cell_item(Vector3(_position.x - (worldSize / 2), _position.y, _position.z - (worldSize / 2)), _tile)
	
func set_tile(_position, _tile, _orientation):
	pass
	objects.set_cell_item(Vector3(_position.x - (worldSize / 2), _position.y + 5, _position.z - (worldSize / 2)), _tile, _orientation)
