extends Node

var mocap = Mocap.new()
var nodes = []
var material = StandardMaterial3D.new()
var selected_node = StandardMaterial3D.new()
var time = 0

@export var node_index: int = 0

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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	if time <= 0.016:
		return;
		
	time = 0
	
	for i in range(nodes.size()):
		nodes[i].position = mocap.get_position(i) / 1000
	
	mocap.next_frame()
