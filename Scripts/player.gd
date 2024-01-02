extends Node3D

@export var move_speed = 12
@export var zoom_speed = 50
@export var angle: float= -70.0
@export var border_margin_for_mouse: int = 30

@onready var camera_3d: Camera3D = $Camera3D
@onready var terrain_node_3d = $"../TerrainBuilder"
@onready var selector = $"../Selector"

var min_y := 8 
var max_y := 50 

var speed_factor = 0.2 
var current_speed = Vector3.ZERO
var current_mouse_speed = Vector3.ZERO

func _ready():
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

	min_position.x = min(min_position.x, 0)
	min_position.z = min(min_position.z, 0)
	max_position.x = max(max_position.x, terrain_node_3d.worldSize)
	max_position.z = max(max_position.z, terrain_node_3d.worldSize)
	
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
		self.position = new_position.lerp(self.position, delta * 8)

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
	var ray_length = 50.0
	var ray_from = camera_3d.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera_3d.project_ray_normal(mouse_pos) * ray_length

	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = ray_from
	ray_query.to = ray_to
	var intersection = space_state.intersect_ray(ray_query)
	
	if (intersection and intersection["collider"] and intersection["collider"] is StaticBody3D):
		if intersection.has("position"):
			var static_body: StaticBody3D = intersection["collider"]
			set_selector_position(static_body)
			action_build(static_body, intersection)
		else:
			print("No intersection found")
			selector.visible = false

func set_selector_position(static_body):
	selector.visible = true
	var tile_position = static_body.get_parent_node_3d().position
	selector.position = Vector3(tile_position.x,tile_position.y + 0.6, tile_position.z)

func action_build(static_body, intersection):
	if Input.is_action_just_pressed("click"):
		print("Vous avez cliqué sur la tuile : ", intersection.position)
		var house = preload("res://Models/OBJ format/unit_house.obj")
		var has_mesh_instance = false
		for child in static_body.get_children():
			if child is MeshInstance3D:
				has_mesh_instance = true
				break

		if has_mesh_instance:
			print("Un MeshInstance3D est présent parmi les enfants du StaticBody3D.")
		else:
			print("Aucun MeshInstance3D n'est présent parmi les enfants du StaticBody3D.")
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = house
			mesh_instance.transform.origin = Vector3(static_body.position.x, static_body.position.y + 0.4, static_body.position.z)
			mesh_instance.scale = Vector3(1, 1, 1)
		
			selector.visible = false
			static_body.add_child(mesh_instance)

func _process(delta):
	moveKeyboard(delta)
	moveMouse(delta)
	zoomMouse(delta)
	

