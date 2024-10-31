extends CameraControllerBase

# required exports
@export var top_left: Vector2
@export var bottom_right: Vector2
@export var autoscroll_speed: Vector3 = Vector3(1, 0, 1)
# for draw line
@export var box_width: float = 10.0
@export var box_height: float = 10.0

var current_position: Vector3

func _ready() -> void:
	# initializing
	super()
	current_position = Vector3(top_left.x, target.position.y, top_left.y)
	make_current()

# GOAL: this should south east. There should be a boundary box within the screen,
# and when the vessel hits it while idle, it will push the vessel at the speed of the 
# autoscroll.
func _process(delta: float) -> void:
	# make sure other cameras don't scroll
	if !current or target == null:
		return

	# update position of the autoscrolling box
	current_position.x += autoscroll_speed.x * delta
	current_position.z += autoscroll_speed.z * delta
	position = current_position + Vector3(0, dist_above_target, 0)

	# defining box relative to curr position
	var frame_left_x = current_position.x - 5
	var frame_top_z = current_position.z - 5
	var frame_right_x = current_position.x + 5
	var frame_bottom_z = current_position.z + 5
	
	# push forward if touching border x
	if target.position.x < frame_left_x:
		target.position.x = frame_left_x 

	# push forward if touching border z
	if target.position.z < frame_top_z:
		target.position.z = frame_top_z 
	
	#block from going out of screen
	if target.position.x > frame_right_x:
		target.position.x = frame_right_x 
		
	if target.position.z > frame_bottom_z:
		target.position.z = frame_bottom_z 
		
	# Draw the frame if enabled
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
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
