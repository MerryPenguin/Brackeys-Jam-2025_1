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

var origin : ConnectorNode
var destination : ConnectorNode

signal belt_connected(belt)


func _ready():
	if $Path2D.curve == null:
		$Path2D.curve = Curve2D.new()

func activate(connector_node : ConnectorNode):
	# whoever spawns the conveyor should call this
	origin = connector_node
	state = states.DRAWING
	
func _process(_delta):
	match state:
		states.DRAWING:
			if not Input.is_action_pressed("draw_conveyor_belt"):
				stop_drawing() # note: we don't care whether the destination is valid yet.
			else:
				if Time.get_ticks_msec() > time_at_last_poll + polling_interval:
					if not point_too_close():
						add_point()
		states.OPERATING:
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
	if proposed_destination_is_valid():
		var connector_reached : ConnectorNode = get_nearest_input_connector()
		connector_reached.conveyor_belt = self
		destination = connector_reached
		print("Connected a conveyor belt! ", origin.name, ", " , destination.name)
		belt_connected.emit(self)
	else:
		# TODO: drop all the contents on the ground, flash and queue_free
		origin.conveyor_belt = null
		queue_free()

func destruct():
	#TODO: drop the widgets on the ground
	queue_free()
	
	
	

func proposed_destination_is_valid():
	var valid = true
	var nearby_input_connectors = get_nearby_inputs()
	if nearby_input_connectors == null or nearby_input_connectors.is_empty():
		valid = false # no inputs to connect to at mouse location
	elif get_nearest_input_connector().get_parent() == origin.get_parent():
		valid = false # connected to the same building
	return valid

func get_nearby_inputs():
	var all_connectors = get_tree().get_nodes_in_group("connectors")
	var all_inputs = all_connectors.filter(is_input_node)
	var nearby_inputs = all_inputs.filter(is_node_near_cursor)
	return nearby_inputs

func get_nearest_input_connector():
	var nearby_inputs = get_nearby_inputs()
	if not nearby_inputs.is_empty():
		return nearby_inputs[0]

func is_node_near_cursor(node):
	var tolerance_sq = 32*32
	if node.global_position.distance_squared_to(get_global_mouse_position()) < tolerance_sq:
		return true

func is_input_node(node):
	return node.type == node.types.INPUT

func add_new_conveyance(widget: FactoryProductWidget):
	# add a pathfollower2d and give it a reference to the widget we're transporting
	var new_package = ConveyorBeltPackage.new()
	$Path2D.add_child(new_package)
	new_package.add_contents(widget)
	new_package.conveyor_belt = self

func _on_new_widget_received(widget : FactoryProductWidget):
	add_new_conveyance(widget)
	

func receive_product(widget):
	_on_new_widget_received(widget)
