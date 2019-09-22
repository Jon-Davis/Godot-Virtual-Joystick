extends Control

# boolean to check for mouse events
export var persistent = false
export var mouse_trigger = BUTTON_LEFT

#fields for the background circle
export var background_color = Color(0.5,0.5,0.5,0.5)
export var background_stroke_width = 1
export var background_stroke_color = Color(1,1,1)
export var background_radius = 50
export var background_resolution = 64

#fields for the forground circle
export var foreground_color = Color(1,1,1)
export var foreground_stroke_width = 1
export var foreground_stroke_color = Color(0,0,0)
export var foreground_radius = 10
export var foreground_resolution = 64

# fake index for mouse
const MOUSE_INDEX = -2
# stores the current index that represents the finger controlling the analog controller
var index = -1
# stores the inital down position
export var start_pos = Vector2(0,0)
# stores the current down position
var curr_pos = start_pos
# stores the current vector from -1,-1 to 1,1
var value = Vector2(0,0)

func _ready():
	curr_pos = start_pos
	
func get_value():
	return value
	
func is_active():
	return index != -1

# Handles touch for the virtual analog controller and supports multi-touch
func _input(event):
	if event is InputEventScreenTouch:
		handle_press(event,event.get_index())
	elif event is InputEventMouseButton and event.get_button_index() == mouse_trigger:
		handle_press(event,MOUSE_INDEX)
	# if the current touch controller moves
	elif (event is InputEventScreenDrag and event.get_index() == index) or (event is InputEventMouseMotion and index == MOUSE_INDEX):
		var dist = (event.get_position() - start_pos).clamped(background_radius);
		curr_pos = start_pos + dist
		value = (dist / background_radius).reflect(Vector2(1,0))
		self.update()

func handle_press(event, _index):
	# if the current touch is empty and a new valid touch is recv
	if index == -1 and event.is_pressed() and self.get_rect().has_point(event.get_position()):
		index = _index
		if not persistent:
			start_pos = event.get_position()
		curr_pos = start_pos
		self.update()
	# if the current touch controlling the virtual analog controller is released
	elif (index == _index) and not event.is_pressed():
		index = -1
		curr_pos = start_pos
		value = Vector2(0,0)
		self.update()
	
func _draw():
	if index != -1 or persistent:
		var radius = 50
		_draw_circle(start_pos, background_radius, background_color, background_resolution, background_stroke_width, background_stroke_color)
		_draw_circle(curr_pos, foreground_radius, foreground_color, foreground_resolution, foreground_stroke_width, foreground_stroke_color)
	
func _draw_circle(center, radius, color, nb_points, stroke_width, stroke_color):
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])
	for i in range(nb_points+1):
	    var angle_point = deg2rad(i * 360 / nb_points - 90)
	    points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)
	if (stroke_width > 0):
		points_arc.remove(0)
		draw_polyline(points_arc, stroke_color)
