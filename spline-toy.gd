extends Node2D

var points = []
var current_pos = Vector2(0,0)
var prev_pos = Vector2(0,0)

var points_buffer = []
var buffer_start = 0

var time_per_point = 1.
var current_time = 0


func quadratic_bezier_interpolate2D(start: Vector2, anchor: Vector2, end: Vector2, x: float) -> Vector2:
	var anchor1 = lerp(start, anchor, x)
	var anchor2 = lerp(anchor, end, x)

	return lerp(anchor1, anchor2, x)

func cubic_bezier_interpolate2D(start: Vector2, anchor1: Vector2, anchor2: Vector2, end: Vector2, x: float) -> Vector2:
	return Vector2(
		bezier_interpolate(start.x, anchor1.x, anchor2.x, end.x, x),
		bezier_interpolate(start.y, anchor1.y, anchor2.y, end.y, x),
	)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_time += delta

	if points.size() > 0:
		var next_index = buffer_start
		var target_index = wrap(buffer_start + 1, 0, points.size())
		current_pos = quadratic_bezier_interpolate2D(prev_pos, points[next_index], points[target_index], current_time / time_per_point)

	if current_time*2 >= time_per_point:
		buffer_start += 1
		current_time = 0
		prev_pos = current_pos

		if buffer_start >= points.size():
			buffer_start = 0

	queue_redraw()

func _draw() -> void:
	for point in points:
		draw_circle(point, 10, Color.ANTIQUE_WHITE)
	
	draw_circle(current_pos, 10, Color.AQUAMARINE)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_position = event.position
				print("mouse clicked at ", mouse_position)

				if points.size() == 0:
					current_pos = mouse_position
					prev_pos = mouse_position

				self.points.append(mouse_position)
				print(self.points)
