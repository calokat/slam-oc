class_name Mocap

var contents: PackedByteArray
var total_frames: int
var total_nodes: int
var vector_size: int
var base_offset: int
var node_size: int
var frame_size: int
var current_frame: int

var motion_interpolator = MotionInterpolator.new()

func _init(
	node_index = 60,
	file_name = "res://../tools/c3d-processor/salsa.bin"
) -> void:
	var file = FileAccess.open(file_name, FileAccess.READ)
	
	self.contents = file.get_buffer(file.get_length())
	self.total_frames = self.contents.decode_s32(0)
	self.total_nodes = self.contents.decode_s32(4)
	self.vector_size = self.contents.decode_s32(8)
	
	self.base_offset = 12
	self.node_size = (self.vector_size * 4)
	self.frame_size = self.node_size * self.total_nodes
	
	self.current_frame = 0

	var n_plus_one_frame = _wrap_frame(self.current_frame + 1)
	var n_plus_two_frame = _wrap_frame(self.current_frame + 2)
	var n_plus_three_frame = _wrap_frame(self.current_frame + 3)

	var posCurrent = get_position(self.current_frame, node_index)
	var posPlusOne = get_position(n_plus_one_frame, node_index)
	var posPlusTwo = get_position(n_plus_two_frame, node_index)
	var posPlusThree = get_position(n_plus_three_frame, node_index)

	motion_interpolator.load_buffer([posCurrent, posPlusOne, posPlusTwo, posPlusThree])

# Iterates the mocap object to the next frame, if
# it reaches the end, the current_frame is set to 0
# looping the motion
func next_frame(node_index: int) -> int:
	self.current_frame = _wrap_frame(self.current_frame + 1)
	var staged_frame = _wrap_frame(self.current_frame + 4)

	var staged_position = get_position(staged_frame, node_index)
	motion_interpolator.push_position(staged_position)

	return self.current_frame

func _wrap_frame(frame_index: int) -> int:
	if frame_index >= self.total_frames:
		return  frame_index - self.total_frames
	return frame_index

func _get_frame_offset(frame_index: int, node_index := 0) -> int:
	var frame_offset = self.base_offset + frame_index * self.frame_size
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

func get_position(frame_index: int, node_index: int) -> Vector3:
	var frame_offset = _get_frame_offset(frame_index, node_index)
	
	var x = self.contents.decode_float(frame_offset)
	var y = self.contents.decode_float(frame_offset + 4)
	var z = self.contents.decode_float(frame_offset + 8)
	
	return Vector3(x, y, z) / 1000.

func interpolate_position(normalized_time: float) -> Vector3:
	return motion_interpolator.interpolate(normalized_time)
	
func get_direction(node_index: int) -> Vector3:
	var frame_offset = _get_frame_offset(current_frame, node_index)
	
	var theta = self.contents.decode_float(frame_offset + 12)
	var phi = self.contents.decode_float(frame_offset + 16)
	
	return _spherical_to_unit_vector(theta, phi)

func get_direction_from_adj_plane(position: Vector3, node_index: int) -> Vector3:
	var a_pos = get_position(current_frame, (node_index + 1) % self.total_nodes)
	var b_pos = get_position(current_frame, (node_index + 2) % self.total_nodes)
	var ac = position - a_pos
	var bc = position - b_pos
	return ac.cross(bc)
