extends Node3D

var heading = Vector3.ZERO
var speed = 2.0
var elapsed = 0
var mocap = Mocap.new()


func change_heading():
	heading = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_heading()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed += delta
	
	if elapsed < 0.016:
		return
	
	elapsed = 0
	
	position = mocap.get_position(0) / 500
	rotation = mocap.get_direction_from_adj_plane(0) / 500
	
	mocap.next_frame()
