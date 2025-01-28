extends Node3D

@export var acc: Vector3 = Vector3.ZERO
var current_vel = Vector3.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_vel += acc * delta
	self.position += current_vel * delta
	pass
