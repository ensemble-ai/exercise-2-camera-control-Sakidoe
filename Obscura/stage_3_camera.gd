extends CameraControllerBase

# exports
@export var follow_speed: float = 200.0 
@export var catchup_speed: float = 30 
@export var leash_distance: float = 20.0

var current_position: Vector3
var vessel_tracker: Vector3 
var is_moving: bool = false  

func _ready() -> void:
	#initializing
	super()
	current_position = position
	vessel_tracker = target.position 
	make_current()

func _process(delta: float) -> void:
	# making sure if it's the camera selected
	if !current or target == null:
		return

	# distance calculations between camera and vessel
	var distance_target = target.position.distance_to(position)

	# movement check
	is_moving = vessel_tracker.distance_to(target.position) > 0.1 
	vessel_tracker = target.position

	#if idle or not
	var speed: float
	if is_moving:
		speed = follow_speed
	else:
		speed = catchup_speed

	# camera movement
	if distance_target > leash_distance:
		position += ((target.position - position).normalized()) * speed * delta  # Move camera closer if it's too far
	else:
		position = position.lerp(target.position, speed * delta / distance_target)  # Smooth follow with lerp

	# ensure y camera movements
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
