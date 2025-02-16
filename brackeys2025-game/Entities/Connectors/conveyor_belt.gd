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

func _ready():
	pass
	
func _process(delta):
	match state:
		states.DRAWING:
			pass
		states.OPERATING:
			pass

func add_new_conveyance(widget: ProductionWidget):
	# add a pathfollower2d and give it a reference to the widget we're transporting
	var new_package = ConveyorBeltPackage.new()
	$Path2D.add_child(new_package)
	

func _on_new_widget_received(widget : ProductionWidget):
	add_new_conveyance(widget)
	
