extends CameraControllerBase



func _ready() -> void:
	# setting initial states for this camera.
	current = true
	make_current()

func _process(delta: float) -> void:
	if target:
		# lock x and z coords to vessel.
		position.x = target.position.x
		position.z = target.position.z
		# keep camera y distance uniform
		position.y = target.position.y + dist_above_target

	# call draw logic only if the camera is active
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
