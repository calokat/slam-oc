extends Node3D

var frame_time: float = 0.017
var time_count: float

var node_index: int = 24

var mocap = Mocap.new(self.node_index);

var camera: Camera3D
var viewport: SubViewport

func _ready() -> void:
	viewport = SubViewport.new()
	camera = Camera3D.new()

	viewport.size = Vector2i(128, 128)

	viewport.add_child(camera)
	add_child(viewport)

func _physics_process(delta: float) -> void:
	time_count += delta
	var normalized_time: float = time_count / frame_time

	position = mocap.interpolate_position(normalized_time)
	camera.position = position.rotated(Vector3(1.,0.,0.), deg_to_rad(-90.))
	var direction = (mocap
		.get_direction_from_adj_plane(position, node_index)
		.rotated(Vector3(1.,0.,0.), deg_to_rad(90))
		.normalized()*10.
	)
	
	look_at(position + direction)
	camera.look_at(position + direction)

func _process(delta: float) -> void:
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var texture = viewport.get_texture()
	material.albedo_texture = texture
	$"../../BoidView".mesh.material = material
	var slam = SlamInstance.new()
	slam.sense(texture.get_image().save_png_to_buffer(), Vector3.ZERO)

func _on_timer_timeout() -> void:
	time_count = 0
	mocap.next_frame(self.node_index)
