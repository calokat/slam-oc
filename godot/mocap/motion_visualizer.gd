extends Node

var cylinder: CSGCylinder3D
var material = StandardMaterial3D.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.albedo_color = Color.WHITE
	cylinder = CSGCylinder3D.new()
	cylinder.radius = 0.02
	cylinder.height = 1.
	cylinder.position = Vector3(0., 0., 0.)
	cylinder.material = material

	var direction_vector = Vector3(1.0, 1.0, -1.0)  # Example direction

	# By default, CSGCylinder3D points up (along Y axis)
	var up_vector = Vector3.UP

	# Calculate the rotation needed to align with direction
	if direction_vector != up_vector:
		var rotation_axis = up_vector.cross(direction_vector.normalized())
		var rotation_angle = up_vector.angle_to(direction_vector)
		cylinder.rotate(rotation_axis.normalized(), rotation_angle)


	add_child(cylinder)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
