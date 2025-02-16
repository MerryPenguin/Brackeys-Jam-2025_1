## Keep track of specific requirements and inventory for FactoryMachines

class_name RequirementsManifest extends Resource


@export var widget_scene : PackedScene
@export var quantity_required : int = 1
@export var max_capacity : int = 10
@export var currently_held : int = 0
var widget_name : String


func get_widget_name():
	return widget_scene.get_state().get_node_name(0)
	
func is_full():
	return currently_held >= max_capacity
	
func add(quantity):
	currently_held += quantity

func requirements_met():
	return currently_held >= quantity_required
	
