class_name Mocap

var contents: PackedByteArray
var total_frames: int
var total_nodes: int
var vector_size: int
var base_offset: int
var node_size: int
var frame_size: int
var current_frame: int

func _find_nonzero_direction():
	for n in self.total_nodes:
		var dir = get_direction(n);
		if Vector2(dir.x, dir.y).length() > 0.0:
			print(n)
			print(get_direction(n))

func _init(file_name = "res://tools/c3d-processor/salsa.bin") -> void:
	var file = FileAccess.open(file_name, FileAccess.READ)
	
	self.contents = file.get_buffer(file.get_length())
	self.total_frames = self.contents.decode_s32(0)
	self.total_nodes = self.contents.decode_s32(4)
	self.vector_size = self.contents.decode_s32(8)
	
	self.base_offset = 12
	self.node_size = (self.vector_size * 4)
	self.frame_size = self.node_size * self.total_nodes
	
	self.current_frame = 0
	
	_find_nonzero_direction()

# Iterates the mocap object to the next frame, if
# it reaches the end, the current_frame is set to 0
# looping the motion
func next_frame() -> int:
	self.current_frame += 1
	if self.current_frame >= self.total_frames:
		self.current_frame = 0
	return self.current_frame

func _get_frame_offset(node_index = 0) -> int:
	var frame_offset = self.base_offset + self.current_frame * self.frame_size
	frame_offset = frame_offset + node_index * self.node_size
	return frame_offset
	
func _spherical_to_unit_vector(theta_deg: float, phi_deg: float) -> Vector3:
	var theta = deg_to_rad(theta_deg)
	var phi = deg_to_rad(phi_deg)

	return Vector3(
	   sin(theta) * cos(phi),
	   sin(theta) * sin(phi),
	   cos(theta)
	)

func get_position(node_index = 0) -> Vector3:
	var frame_offset = _get_frame_offset(node_index)
	
	var x = self.contents.decode_float(frame_offset)
	var y = self.contents.decode_float(frame_offset + 4)
	var z = self.contents.decode_float(frame_offset + 8)
	
	return Vector3(x, y, z)
	
func get_direction(node_index = 0) -> Vector3:
	var frame_offset = _get_frame_offset(node_index)
	
	var theta = self.contents.decode_float(frame_offset + 12)
	var phi = self.contents.decode_float(frame_offset + 16)
	
	return _spherical_to_unit_vector(theta, phi)
