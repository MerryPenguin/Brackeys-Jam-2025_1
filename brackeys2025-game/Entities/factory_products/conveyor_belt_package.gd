## Conveyor Belt Package moves widgets along conveyor belts

class_name ConveyorBeltPackage extends PathFollow2D

@export var speed : float = 80.0
var widget : FactoryProductWidget

func _process(delta):
	progress += speed * delta # in pixels
	progress_ratio = min(progress_ratio, 1.0)

func add_contents(contents_node : FactoryProductWidget):
	if widget != null:
		push_warning("conveyor_belt_package already has contents, tried to add: ", contents_node)
		return
	widget = contents_node
	if not widget.is_inside_tree():
		add_child(widget)
	else:
		push_warning("conveyor_belt_package tried adding contents, but the widget is still in the tree.")

func release_contents(contents_node : FactoryProductWidget):
	if contents_node == widget:
		queue_free()
		# assume someone else is spawning the unowned widget?
		
