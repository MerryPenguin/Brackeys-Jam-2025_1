## Conveyor Belt: can transport items (factory_product_widget) between machines

# Needs a drawing state and an operating or conveying state
# Needs to:
	# receive new widgets from factory_machines
	# deliver widgets to:
		# factory_machines
		# storage_chests
		# customers (maybe)


class_name ConveyorBelt extends Node2D

enum draw_modes { TILEMAP, SMOOTH_LINE, CARDINAL_LINE }
var draw_mode : draw_modes = draw_modes.TILEMAP

enum states { DRAWING, OPERATING }
var state = states.OPERATING
var desired_points : PackedVector2Array = []
var tilemap_path : Array[Vector2i]


var polling_interval : int = 20 # msec
var time_at_last_poll : int = 0

var origin : ConnectorNode
var destination : ConnectorNode

var previous_tile_coord : Vector2

signal belt_connected(belt)


func _ready():
	validate_requirements()
	setup_draw_mode()
	add_point(get_global_mouse_position())

func validate_requirements():
	if $Path2D.curve == null:
		$Path2D.curve = Curve2D.new()

func setup_draw_mode():
	var desired_draw_mode = Config.get_config('GameSettings', 'ConveyorBeltStyle', "TILEMAP")
	match desired_draw_mode:
		"TILEMAP":
			$TileMapLayer.show()
			$Line2D.hide()
			draw_mode = draw_modes.TILEMAP
		"SMOOTH_LINE":
			$TileMapLayer.hide()
			$Line2D.show()
			draw_mode = draw_modes.SMOOTH_LINE
		"CARDINAL_LINE":
			$TileMapLayer.hide()
			$Line2D.show()
			draw_mode = draw_modes.CARDINAL_LINE
			

func activate(connector_node : ConnectorNode):
	# whoever spawns the conveyor should call this
	origin = connector_node
	state = states.DRAWING
	
func _process(_delta):
	match state:
		states.DRAWING:
			if Input.is_action_just_released("draw_conveyor_belt"):
				add_point(get_global_mouse_position())
				stop_drawing() # note: we don't care whether the destination is valid yet.
			else:
				if Time.get_ticks_msec() > time_at_last_poll + polling_interval:
					if not point_too_close():
						# TODO: Change this to virtual cursor for gamepads
						add_point(get_global_mouse_position())
		states.OPERATING:
			pass

func move_goods():
	# Maybe just let the packages move themselves
	#for package : ConveyorBeltPackage in $Path2D:
		#package.move(delta)
	pass

func add_point(location):
	var stepped_location = location.snapped(Globals.grid_size)
	var path : Path2D = $Path2D
	
	
	if path.curve.point_count > 0 and is_zero_approx(path.curve.get_closest_point(stepped_location).distance_squared_to(stepped_location)):
		return
	
	var last_point : Vector2 = location
	if not desired_points.is_empty():
		last_point = desired_points[-1]
	if draw_mode != draw_modes.SMOOTH_LINE:
		if last_point.x != stepped_location.x and last_point.y != stepped_location.y:
			# make an extra point, because user moved diagonally
			if abs(last_point.x - stepped_location.x) > abs(last_point.y - stepped_location.y):
				add_point(Vector2(stepped_location.x, last_point.y))
			else:
				add_point(Vector2(last_point.x, stepped_location.y))
		desired_points.push_back(stepped_location)
	else:
		desired_points.push_back(location)
	
	$Path2D.curve.add_point(desired_points[-1])
	if draw_mode == draw_modes.TILEMAP:
		update_tilemap(desired_points[-1])
	else: # SMOOTH_LINE or #CARDINAL_LINE
		$Line2D.add_point(desired_points[-1])


func update_tilemap(global_location): # works, but doesn't incorporate Globals.grid_size
	# method intended to draw a continuous pipe using Godot tilemap
	## BUG: If user draws too quickly, line creation fails.
	
	# Note: tilemap is scaled Vector2(4.0,4.0)
	var tilemap : TileMapLayer = $TileMapLayer
	var tilemap_local_pos = tilemap.to_local(global_location) # Does this account for scale of tilemap?
	var tilemap_coord : Vector2i = tilemap.local_to_map(tilemap_local_pos)
	print(tilemap_coord, " at scale: ", tilemap.scale)
	
	if tilemap_path.is_empty():
		tilemap_path.push_back(tilemap_coord)
	else:
		var last_tile_coord = tilemap_path[-1]
		# Convert Vector2i to Vector2 for calculations
		var last_tile_coord_vec2 = Vector2(last_tile_coord)
		var tilemap_coord_vec2 = Vector2(tilemap_coord)
		
		var distance = last_tile_coord_vec2.distance_to(tilemap_coord_vec2)
		var direction = (tilemap_coord_vec2 - last_tile_coord_vec2).normalized()
		
		for i in range(1, int(distance) + 1):
			var intermediate_coord_vec2 = last_tile_coord_vec2 + direction * i
			var intermediate_coord = Vector2i(intermediate_coord_vec2) # Convert back to Vector2i
			if intermediate_coord != tilemap_path[-1]:
				tilemap_path.push_back(intermediate_coord)
	
	if tilemap_path.size() > 1:
		tilemap.set_cells_terrain_path(tilemap_path, 0, 0)
		
	previous_tile_coord = tilemap_coord


func point_too_close():
	var tolerance_sq = Globals.grid_size.x * Globals.grid_size.y
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
	var path : Path2D = $Path2D
	if path.curve.point_count > 1 and path.curve.get_baked_length() > 0:
		# add a pathfollower2d and give it a reference to the widget we're transporting
		var new_package = ConveyorBeltPackage.new()
		if path.curve.get_baked_length() > 0:
			path.add_child(new_package) ## BUG: We get a lot of errors about zero length interval here.
		else:
			breakpoint
		new_package.add_contents(widget)
		new_package.conveyor_belt = self
	else:
		push_warning("ConveyorBelt has less than 2 points or zero length interval.")

func _on_new_widget_received(widget : FactoryProductWidget):
	add_new_conveyance(widget)
	

func receive_product(widget):
	_on_new_widget_received(widget)
