## Conveyor Belt: can transport items (factory_product_widget) between machines

# Needs a drawing state and an operating or conveying state
# Needs to:
	# receive new widgets from factory_machines
	# deliver widgets to:
		# factory_machines
		# storage_chests
		# customers (maybe)


class_name ConveyorBelt extends Node2D

enum states { DRAWING, OPERATING }
var state = states.OPERATING
var desired_points : PackedVector2Array = []

var polling_interval : int = 100 # msec
var time_at_last_poll : int = 0

var from : ConnectorNode
var to : ConnectorNode


func _ready():
	if $Path2D.curve == null:
		$Path2D.curve = Curve2D.new()

func activate(connector_node : ConnectorNode):
	# whoever spawns the conveyor should call this
	from = connector_node
	state = states.DRAWING
	
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
			#if from != null and to != null:
				#move_goods()
			pass

func move_goods():
	# Maybe just let the packages move themselves
	#for package : ConveyorBeltPackage in $Path2D:
		#package.move(delta)
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
	var nearby_input_connectors = get_nearby_inputs()
	if nearby_input_connectors != null and not nearby_input_connectors.is_empty():
		var connector_reached : ConnectorNode = nearby_input_connectors[0]
		connector_reached.conveyor_belt = self
		to = connector_reached
		
		print("Connected a conveyor belt!")
	else:
		# TODO: spawn a new output connector
		pass

func get_nearby_inputs():
	var all_inputs = get_tree().get_nodes_in_group("connectors")
	var nearby_inputs = all_inputs.filter(is_node_near_cursor)
	return nearby_inputs

func is_node_near_cursor(node):
	var tolerance_sq = 32*32
	if node.global_position.distance_squared_to(get_global_mouse_position()) < tolerance_sq:
		return true
	

func add_new_conveyance(widget: FactoryProductWidget):
	# add a pathfollower2d and give it a reference to the widget we're transporting
	var new_package = ConveyorBeltPackage.new()
	$Path2D.add_child(new_package)
	new_package.add_contents(widget)
	new_package.destination = to

func _on_new_widget_received(widget : FactoryProductWidget):
	add_new_conveyance(widget)
	

func receive_product(widget):
	_on_new_widget_received(widget)
