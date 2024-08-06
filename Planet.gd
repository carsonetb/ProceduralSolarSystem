@tool
extends Node3D

@export var planet_data: PlanetData:
	set(val):
		planet_data = val
		on_data_changed()
		
		if planet_data != null && !planet_data.is_connected("changed", on_data_changed):
			planet_data.connect("changed", on_data_changed)
			
@export var fake_orbit_in_editor: bool = false
			
@export_range(0, 10000, 0.00000001) var velocity_x: float = 0
@export_range(0, 10000, 0.00000001) var velocity_y: float = 0
@export_range(0, 10000, 0.00000001) var velocity_z: float = 0
@export_range(0, 10000, 0.00000001) var mass: float
@export var unmoving: bool = false
@export var fake_orbit: bool = false
@export var fake_orbit_around: Node3D
@export var fake_orbit_speed: float = 0
@export_range(0, 360) var fake_orbit_angle: float = 0
var velocity: Vector3 = Vector3.ZERO
@export var fake_orbit_distance: float = 0
var fake_orbit_editor_original_position: Vector3 = Vector3.ZERO
@export var rotation_speed: float = 0
@export var rotate_in_editor: bool = false
@export var rotate_planet: bool = false
@onready var previous_position: Vector3 = position
@onready var game_camera: Camera3D = get_parent().get_node("GameCamera")
@export var disable_distance_culling: bool = false
var original_clickbox_radius: float = 0
var draw: Draw3D

func _ready():
	on_data_changed()
	add_to_group("Planets", true)
	velocity = Vector3(velocity_x, velocity_y, velocity_z)
		
	Globals.ready_to_coll = true
	
	if get_node_or_null("CameraClickbox"):
		original_clickbox_radius = $CameraClickbox/CollisionShape3D.shape.radius
		
	draw = Draw3D.new()
	draw.name = "DRAW_NODE"
	add_child(draw)
	
func _process(delta):
	if !Engine.is_editor_hint():
		draw.clear()
		draw.rotation = -rotation
		
		if Input.is_action_just_pressed("toggle_icon_visibility"):
			if get_node_or_null("Icon"):
				$Icon.fixed_size = !$Icon.fixed_size
	
	previous_position = position
	
	if !Engine.is_editor_hint() && !unmoving:
		for planet in get_tree().get_nodes_in_group("Planets"):
			if planet != self:
				velocity += ((planet.position - position).normalized() * ((mass * planet.mass) / position.distance_to(planet.position))) * delta * 60
		
		var simuvelocity = velocity
		var simuposition = position
		var trajectory = []
		
		for i in range(1024):
			for planet in get_tree().get_nodes_in_group("Planets"):
				if planet != self:
					simuvelocity += ((planet.position - simuposition).normalized() * ((mass * planet.mass) / simuposition.distance_to(planet.position)))
		
			simuposition += simuvelocity
			trajectory.append(simuposition)
			
		#for i in range(trajectory.size() - 1):
		#	DebugDraw3D.draw_line(trajectory[i], trajectory[i + 1], Color.WHITE)
		
		position += velocity * delta * 60
	
	if (!Engine.is_editor_hint() || fake_orbit_in_editor) && fake_orbit:
		# Calculate degrees to turn based on speed (radius/arc-length)
		fake_orbit_angle += rad_to_deg(fake_orbit_speed / fake_orbit_distance) * delta * 60
		
		# Set position based on orbit (this is only in the 2D plane for now).
		position = fake_orbit_around.position + Vector3(cos(deg_to_rad(fake_orbit_angle)), 0, sin(deg_to_rad(fake_orbit_angle))) * fake_orbit_distance
		
		if !Engine.is_editor_hint():
			draw.circle_XZ(fake_orbit_around.position - position, fake_orbit_distance, Color.WHITE)
	
	if (!Engine.is_editor_hint() || rotate_in_editor) && rotate_planet:
		rotation_degrees.y += rotation_speed * delta * 60
		
	if !Engine.is_editor_hint():
		if position.distance_to(game_camera.position) > 10 && !disable_distance_culling:
			for child in get_children():
				if child is MeshInstance3D && child.name != "DRAW_NODE":
					child.visible = false
		else:
			for child in get_children():
				child.visible = true
		
		if get_node_or_null("CameraClickbox"):
			$CameraClickbox/CollisionShape3D.shape.radius = clamp(original_clickbox_radius * (position.distance_to(game_camera.position) / 2), original_clickbox_radius, 9999999)
	
func on_data_changed():
	planet_data.min_height = 999999.0
	planet_data.max_height = -999999.0
	for child in get_children():
		if child is MeshInstance3D:
			var face := child as PlanetMeshFace
			face.regenerate_mesh(planet_data)
		
	Globals.ready_to_coll = true

func _on_camera_clickbox_input_event(camera, event: InputEvent, click_pos, normal, shape_idx):
	if event.is_action_released("click"):
		game_camera.position = position
		game_camera.current_planet = self
