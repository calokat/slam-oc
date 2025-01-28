extends Node3D

var heading = Vector3.ZERO
var speed = 2.0
var elapsed = 0
var mocap = Mocap.new()

var position_scale = 1. / 300

var position_buffer = []

var mocap_fps = 2.
var frame_time = 1./mocap_fps
var double_frame_time = frame_time * 2.

func init_position_buffer():
	position_buffer.append(mocap.get_position(0))
	mocap.next_frame()
	position_buffer.append(mocap.get_position(0))
	mocap.next_frame()
	position_buffer.append(mocap.get_position(0))

func iterate_position_buffer():
	position_buffer.pop_front()
	mocap.next_frame()
	position_buffer.append(mocap.get_position(0))

## Uses the three positions in the position buffer to form a quadratic bezier curve
## Basically allows us to chain together bezier curves smoothly to get a realistic
## estimation of motion betwen mocap frames. Intuition for the lerps and anchors
## comes from the video "the beauty of bezier curves" by freya holmer, around 2m:45s
func position_from_buffer_bezier(t: float):
	# Frame time is multiplied by two since the bezier curve every iteration
	var anchor1 = lerp(position_buffer[0], position_buffer[1], t / frame_time)
	var anchor2 = lerp(position_buffer[1], position_buffer[2], t / frame_time)
	var bezier_position = lerp(anchor1, anchor2, t / frame_time)

	return bezier_position

func change_heading():
	heading = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_heading()

	# skip ahead 10k frames
	for i in range(10000):
		mocap.next_frame()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta
	
	if elapsed <= frame_time:
		return
	
	elapsed = 0
	
	position = mocap.get_position(0) / 500
	rotation = mocap.get_direction(0) / 500
	
	mocap.next_frame()
