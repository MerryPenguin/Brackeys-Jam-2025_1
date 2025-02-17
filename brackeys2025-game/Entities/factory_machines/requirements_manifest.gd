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
	
func generate_random_requirement():
	# for customers to create a random manifest
	var random_product = Globals.product_scenes.keys().pick_random()
	widget_scene = Globals.product_scenes[random_product]
	quantity_required = randi()%5
	max_capacity = quantity_required
	widget_name = get_widget_name()
