extends Node3D

var heading = Vector3.ZERO
var speed = 2.0

func change_heading():
	heading = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_heading()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += -basis.z * delta
	basis = basis.slerp(Basis.looking_at(heading), delta)
