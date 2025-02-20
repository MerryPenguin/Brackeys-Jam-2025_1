## Keep track of specific requirements and inventory for FactoryMachines

class_name RequirementsManifest extends Resource


@export var recipe : ProductWidgetRecipe
@export var quantity_required : int = 1
#@export var max_capacity : int = 10
#@export var currently_held : int = 0
var widget_name : String
var icon : Texture2D

func get_widget_name():
	return recipe.product_name
	
#func is_full():
	#return currently_held >= max_capacity
	
#func add(quantity):
	#currently_held += quantity

#func requirements_met():
	##return currently_held >= quantity_required

func get_requirements():
	var requirements : Array = [ recipe, quantity_required]
	return requirements
	
func generate_random_requirement():
	pass
	# for customers to create a random manifest
	#var random_product = Globals.product.keys().pick_random()
	#recipe = Globals.product_recipes[random_product]
	#quantity_required = randi()%5
	#max_capacity = quantity_required
	#widget_name = get_widget_name()
