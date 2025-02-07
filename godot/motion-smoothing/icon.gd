extends Sprite2D

var interp = MotionInterpolator.new()
var total_time: float = 0;
var pos1: Vector3 = Vector3(100, 100, 0)*2;
var pos2: Vector3 = Vector3(100, 200, 0)*2;
var pos3: Vector3 = Vector3(200, 100, 0)*2;
var buffer: Array[Vector3] = [pos2, pos3]

var prev_position: Vector2 = Vector2.ZERO
var prev_velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interp.load_buffer(buffer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	total_time += delta;
	var interval_limit = 1;
	
	if total_time >= interval_limit:
		total_time = 0

	var normalized_time = total_time / interval_limit;

	var pos3d = interp.interpolate(Vector3(position.x, position.y, 0.), normalized_time)
	position = Vector2(pos3d.x, pos3d.y)

	var delta_position = position - self.prev_position
	var current_velocity = delta_position / delta
	var current_accel = (current_velocity - prev_velocity) / delta
	
	prev_position = position
	prev_velocity = current_velocity
	print("current accel: %v, current velocity: %v" % [current_accel, current_velocity])