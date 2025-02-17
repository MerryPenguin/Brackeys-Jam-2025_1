## Conveyor Belt: can transport items (factory_product_widget) between machines

# Needs a drawing state and an operating or conveying state
# Needs to:
	# receive new widgets from factory_machines
	# deliver widgets to:
		# factory_machines
		# storage_chests
		# customers (maybe)


extends Node2D

enum states { DRAWING, OPERATING }
var state = states.DRAWING
var desired_points : PackedVector2Array = []

var polling_interval : int = 100 # msec
var time_at_last_poll : int = 0

func _ready():
	if $Path2D.curve == null:
		$Path2D.curve = Curve2D.new()
	
func _process(_delta):
	match state:
		states.DRAWING:
			if not Input.is_action_pressed("draw_conveyor_belt"):
				stop_drawing()
			else:
				if Time.get_ticks_msec() > time_at_last_poll + polling_interval:
					if not point_too_close():
						add_point()
		states.OPERATING:
			pass

func add_point():
	var location = get_global_mouse_position()
	desired_points.push_back(location)
	$Line2D.add_point(location)
	$Path2D.curve.add_point(location)

func point_too_close():
	var tolerance_sq = 32 * 32
	if desired_points.is_empty():
		return false
	elif desired_points[-1].distance_squared_to(get_global_mouse_position()) < tolerance_sq:
		return true
	else:
		return false
		

func stop_drawing():
	# end the path and check for nearby input nodes.
	# if no nearby input, create an output node for drawing more paths.
	
	state = states.OPERATING

func add_new_conveyance(widget: FactoryProductWidget):
	# add a pathfollower2d and give it a reference to the widget we're transporting
	var new_package = ConveyorBeltPackage.new()
	$Path2D.add_child(new_package)
	new_package.widget = widget
	

func _on_new_widget_received(widget : FactoryProductWidget):
	add_new_conveyance(widget)
	
