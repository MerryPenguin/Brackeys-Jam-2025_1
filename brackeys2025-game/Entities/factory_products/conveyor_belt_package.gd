## Conveyor Belt Package moves widgets along conveyor belts

class_name ConveyorBeltPackage extends PathFollow2D

@export var speed : float = 80.0
var widget : FactoryProductWidget
var destination : ConnectorNode

enum states { WAITING, MOVING, ARRIVED }
var state = states.MOVING


func _ready():
	rotates = false
	loop = false

func _process(delta):
	if not state in [ states.WAITING, states.MOVING ]:
		return # you've already arrived
	
	if is_inside_tree() and get_parent().curve.point_count > 0:
		progress += speed * delta # in pixels
		progress_ratio = min(progress_ratio, 1.0)
		if progress_ratio > 0.95:
			deliver_contents(destination)


func add_contents(contents_node : FactoryProductWidget):
	if widget != null:
		push_warning("conveyor_belt_package already has contents, tried to add: ", contents_node)
		return
	widget = contents_node
	if not widget.is_inside_tree():
		add_child(widget)
		widget.position = Vector2.ZERO
		widget.package = self
	else:
		push_warning("conveyor_belt_package tried adding contents, but the widget is still in the tree.")

func destroy_contents(contents_node : FactoryProductWidget):
	if contents_node == widget:
		queue_free()
		# assume someone else is spawning the unowned widget?
		
func deliver_contents(target : ConnectorNode):
	remove_child(widget)
	target.receive_product(widget)
	queue_free() # we're no longer required
	
	
