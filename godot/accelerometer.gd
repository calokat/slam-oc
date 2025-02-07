extends Node3D

var prev_position: Vector3 = Vector3.ZERO
var prev_velocity: Vector3 = Vector3.ZERO

var target: Node3D

var physics_time = 1./400.

func _ready() -> void:
	target = self.get_parent_node_3d()
	prev_position = target.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var delta_position = target.position - self.prev_position
	var current_velocity = delta_position / physics_time
	var current_accel = (current_velocity - prev_velocity) / (2*physics_time)
	
	prev_position = target.position
	prev_velocity = current_velocity
	#print("acc: %.2f, vel: %.2f, pos: %.2f" % [current_accel.x, current_velocity.x, target.position.x])
