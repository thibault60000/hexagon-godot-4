extends Node3D

@export var move_speed = 12
@export var zoom_speed = 50
@export var angle: float= -50.0
@export var border_margin_for_mouse: int = 30

@onready var camera_3d = $Camera3D
@onready var terrain_map = $"../GridMapTiles"

var min_y := 8 
var max_y := 20 


var zoom_factor = 0.2
var speed_factor = 0.2 
var current_speed = Vector3.ZERO
var current_mouse_speed = Vector3.ZERO

func _ready():
	var test = terrain_map.get_cell_item(Vector3(0,0,0))
	print("test en 0,0,0", test)
	update_camera_angle()

func update_camera_angle():
	var y_range = max_y - min_y
	var y_position = clamp(self.global_transform.origin.y, min_y, max_y)
	var t = (y_position - min_y) / y_range
	var new_angle = lerp(-40, -50, t)
	camera_3d.rotation_degrees.x = new_angle

func get_grid_bounds():
	var min_position = Vector3.INF
	var max_position = -Vector3.INF
	for cell in terrain_map.get_used_cells():
		var cell_position = terrain_map.map_to_local(cell)
		min_position.x = min(min_position.x, cell_position.x)
		min_position.z = min(min_position.z, cell_position.z)
		max_position.x = max(max_position.x, cell_position.x)
		max_position.z = max(max_position.z, cell_position.z)
	return {"min_position": min_position, "max_position": max_position}

func is_within_grid(position):
	var bounds = get_grid_bounds()
	var min_position = bounds["min_position"]
	var max_position = bounds["max_position"]
	return (
		min_position.x <= position.x and position.x <= max_position.x and
		min_position.z + +15 <= position.z and position.z <= max_position.z + 20
	)

func move(delta, direction):
	var new_position = self.global_transform.origin + direction.normalized() * get_speed() * delta
	if is_within_grid(new_position):
		self.translate(direction * get_speed() * delta)

func get_speed():
	return move_speed * (1 + self.global_transform.origin.y * speed_factor)

func moveKeyboard(delta)->void:
	var move_direction = Vector3()
	if Input.is_action_pressed("camera_up"):
		move_direction.z -= 1
	if Input.is_action_pressed("camera_down"):
		move_direction.z += 1
	if Input.is_action_pressed("camera_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("camera_right"):
		move_direction.x += 1

	move(delta, move_direction)

func moveMouse(delta)->void:
	var move_direction = Vector3()
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	if mouse_pos.x < border_margin_for_mouse:
		move_direction.x -= 1
	if mouse_pos.x > viewport_size.x - border_margin_for_mouse:
		move_direction.x += 1
	if mouse_pos.y < border_margin_for_mouse:
		move_direction.z -= 1
	if mouse_pos.y > viewport_size.y - border_margin_for_mouse:
		move_direction.z += 1

	move(delta, move_direction)

func zoomMouse(delta)->void:
	var zoom_direction = 0
	if Input.is_action_just_pressed("zoom_in"):
		zoom_direction -= 1
	if Input.is_action_just_pressed("zoom_out"):
		zoom_direction += 1
	if zoom_direction != 0 and min_y < self.global_transform.origin.y + zoom_direction * zoom_speed * delta and self.global_transform.origin.y + zoom_direction * zoom_speed * delta < max_y:
		self.translate(Vector3(0, zoom_direction * zoom_speed * delta, 0))
	update_camera_angle()

func _physics_process(delta):

	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 1000.0
	var ray_from = camera_3d.project_ray_origin(mouse_pos)
	var ray_to = camera_3d.project_ray_normal(mouse_pos * ray_length)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	var world_intersection = space_state.intersect_ray(query)
	
	if (world_intersection and world_intersection["collider"] and world_intersection["collider"] is GridMap):
		if world_intersection.has("position"):
			var gridmap_position = Vector3(world_intersection.position)
			action_build(gridmap_position)
		else:
			print("No intersection found")

func action_build(gridmap_position):
	if Input.is_action_just_pressed("click"):
		var tile = terrain_map.get_cell_item(gridmap_position)
		print("TILE INDEX ", tile, gridmap_position)
		# terrain_map.set_cell_item(gridmap_position, index, gridmap.get_orthogonal_index_from_basis(selector.basis))
		

func _process(delta):
	moveKeyboard(delta)
	moveMouse(delta)
	zoomMouse(delta)
	

