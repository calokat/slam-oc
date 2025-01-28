extends Node2D

var points = []

var current_pos = Vector2(0,0)
var prev_pos = Vector2(0,0)
var target_point_index = 0

var timer_length = 1
var timer = 0

func quadratic_bezier_interpolate2D(start: Vector2, anchor: Vector2, end: Vector2, x: float) -> Vector2:
	var anchor1 = lerp(start, anchor, x)
	var anchor2 = lerp(anchor, end, x)

	return lerp(anchor1, anchor2, x)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# setting up our timers, one to guide us to the next position
	# and one to transition us between easing functions
	timer += delta

	if timer*1.5 > timer_length:
		timer = 0
		# every tick of the timer, we set our target on a new point
		target_point_index = wrap(target_point_index + 1, 0, points.size())
		prev_pos = current_pos

	if points.size() < 1:
		return

	# our current bezier curve
	var anchor_index = wrap(target_point_index - 1, 0, points.size())
	var after_target_index = wrap(target_point_index + 1, 0, points.size())

	var main_curve_position = quadratic_bezier_interpolate2D(prev_pos, points[anchor_index], points[target_point_index], timer / timer_length)
	var next_curve_position = quadratic_bezier_interpolate2D(current_pos, points[target_point_index], points[after_target_index], timer / timer_length)

	if timer > (timer_length / 4.) && timer < (timer_length / 2.):
		current_pos = lerp(main_curve_position, next_curve_position, (timer - (timer_length / 4.)) / (timer_length / 4.))

	current_pos = main_curve_position

	queue_redraw()

func _draw() -> void:
	for point in points:
		draw_circle(point, 10, Color.ANTIQUE_WHITE)
	
	draw_circle(current_pos, 10, Color.AQUAMARINE)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = event.position
			print("mouse clicked at ", mouse_position)

			if points.size() == 0:
				current_pos = mouse_position
				prev_pos = mouse_position

			self.points.append(mouse_position)
			print(self.points)
