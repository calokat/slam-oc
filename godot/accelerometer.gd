extends Node3D

var prev_position: Vector3 = Vector3.ZERO
var prev_velocity: Vector3 = Vector3.ZERO
#var prev_accel: Vector3 = Vector3.ZERO

var target: Node3D

#var delta_position: Vector3 = Vector3.ZERO
#var delta_velocity = Vector3.ZERO
#var delta_accel = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = self.get_parent_node_3d()
	prev_position = target.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var delta_position = target.position - self.prev_position
	var current_velocity = delta_position / delta
	var current_accel = (current_velocity - prev_velocity) / delta
	
	prev_position = target.position
	prev_velocity = current_velocity
	print("current accel: %v, current velocity: %v" % [current_accel, current_velocity])


# prev_pos = 0
# self.pos = 10
# delta_pos = 10
# delta = 10
