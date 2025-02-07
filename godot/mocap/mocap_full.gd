extends Node

var mocap = Mocap.new(23)
var nodes = []
var material = StandardMaterial3D.new()
var selected_node = StandardMaterial3D.new()
var time = 0

@export var node_index: int = 23

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.albedo_color = Color.WHITE
	selected_node.albedo_color = Color.RED
	
	for i in range(mocap.total_nodes):
		var sphere = CSGSphere3D.new()
		sphere.radius = 0.03
		sphere.position = Vector3(0,0,0)
		sphere.cast_shadow = true;
		if i == node_index:
			sphere.material = selected_node
		else:
			sphere.material = material
		nodes.append(sphere)
		add_child(sphere)

func _on_timer_timeout() -> void:
	for i in range(nodes.size()):
		nodes[i].position = mocap.get_position(mocap.current_frame, i)
	
	mocap.next_frame(node_index)
