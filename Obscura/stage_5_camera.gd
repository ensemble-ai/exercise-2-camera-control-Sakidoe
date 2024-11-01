extends CameraControllerBase
#exports
@export var top_left: Vector2
@export var bottom_right: Vector2
@export var push_ratio: float = 0.5
#box outline.
@export var box_width: float = 13.0
@export var box_height: float = 13.0
func _ready() -> void:
	super()
	make_current()

func _process(delta: float) -> void:
	if !current or target == null:
		return

	# the bounds of the push box.
	var frame_left_x7 = global_position.x - 7
	var frame_top_z7 = global_position.z - 7
	var frame_right_x7 = global_position.x + 7
	var frame_bottom_z7 = global_position.z + 7

	# getting the vel of vessel
	var target_velocity = target.get_velocity()

	# if in box,
	if target.position.x > frame_left_x7 and target.position.x < frame_right_x7 and target.position.z > frame_top_z7 and target.position.z < frame_bottom_z7:
		global_position.x += target_velocity.x * push_ratio * delta
		global_position.z += target_velocity.z * push_ratio * delta
	else:
		# if outside box,
		global_position.x += target_velocity.x * delta
		global_position.z += target_velocity.z * delta

	position.y = target.position.y + dist_above_target

	if draw_camera_logic:
		draw_logic()
	super(delta)

#same as push_box.gd
func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left:float = -box_width / 2
	var right:float = box_width / 2
	var top:float = -box_height / 2
	var bottom:float = box_height / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	await get_tree().process_frame
	mesh_instance.queue_free()
