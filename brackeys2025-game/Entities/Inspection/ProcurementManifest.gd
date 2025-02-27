class_name ProcurementManifest extends Node


@export var widgets_desired : Array[Globals.products]
@export var items_purchased : Array[Globals.products]
@export var items_stolen : Array[Globals.products]

@export var destination_region : Globals.regions = Globals.regions.AMERICAS
@export var carrier : StringName = "Global Logistics Inc" # Could be airline, or shipping company

## TODO: Decide if we need a reference to a node, or just a name or something
# if we don't need it, this class could be a resource
@export var purchasing_agent : CustomerIdentity # Could be RovingCustomer, or ... ?
@export var purchasing_company : Node

func create_random_requirements_list():
	# TODO: check destination and weight the requirements for whatever that destination needs.
	
	
	#var req_text = ""
	
	# Add one simple organic material, so player can progress in early stage
	if randf() < 0.75:
		var basic_recipes = [ Globals.products.ASH, Globals.products.STARCH ]
		widgets_desired.push_back(basic_recipes.pick_random())
	
	# Add 1 to 3 random materials
	for i in range((randi()%3) +1):
		var random_choice = Globals.products.values().pick_random()
		widgets_desired.push_back(random_choice)
		#req_text += Globals.product_recipes[random_choice].product_name + ", "
		
	
