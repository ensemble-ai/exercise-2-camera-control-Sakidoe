extends CameraControllerBase

# required exports
@export var lead_distance : float = 10.0 
@export var push_speed_multiplier : float = 2.0 
@export var return_speed : float = 100.0  
@export var catchup_delay_duration : float = 2.0  
@export var leash_distance : float = 20.0 
 
# to check the location of the vessel
var vessel_tracker : Vector3
# to find the speed of the vessel
var vessel_speed : float = 0.0
# to check if the vessel is moving
var is_moving : bool = false

func _ready() -> void:
	# initializing.
	super()
	vessel_tracker = target.position  
	make_current()

func _process(delta: float) -> void:
	# to keep the movements to this camera
	if !current or target == null:
		return
	
	# calculate vessel's speed, direction, and track it's location.
	vessel_speed = vessel_tracker.distance_to(target.position) / delta
	var vessel_direction = Vector3()
	if vessel_speed > 0:
		vessel_direction = (target.position - vessel_tracker).normalized() 
	vessel_tracker = target.position

	# check if vessel is moving
	is_moving = vessel_speed > 0.1

	if is_moving:
		# find position to successfully push cam in front of vessel
		var desired_position = target.position + vessel_direction * lead_distance

		# assuring leash distance
		if desired_position.distance_to(target.position) > leash_distance:
			desired_position = target.position + (desired_position - target.position).normalized() * leash_distance

		position = position.lerp(desired_position, vessel_speed * push_speed_multiplier * delta / position.distance_to(desired_position))

	else:
		# if idle, recenter cam with vessel
		position = position.lerp(target.position, (return_speed / catchup_delay_duration) * delta / position.distance_to(target.position))

	# insuring y position is uniform
	position.y = target.position.y + dist_above_target

	if current and draw_camera_logic:
		draw_logic()
	super(delta)
	
func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# 5x5 cross variables
	var half_length: float = 2.5
	var cross_height_offset: float = 0.5
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	# horizontal 5x5 line
	immediate_mesh.surface_add_vertex(Vector3(-half_length, cross_height_offset, 0))
	immediate_mesh.surface_add_vertex(Vector3(half_length, cross_height_offset, 0))
	
	# vertical 5x5 line
	immediate_mesh.surface_add_vertex(Vector3(0, cross_height_offset, -half_length))
	immediate_mesh.surface_add_vertex(Vector3(0, cross_height_offset, half_length))
	immediate_mesh.surface_end()

	# white color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE

	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)

	await get_tree().process_frame
	mesh_instance.queue_free()
