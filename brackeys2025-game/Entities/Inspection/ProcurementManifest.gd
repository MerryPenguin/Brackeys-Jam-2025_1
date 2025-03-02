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

func create_random_requirements_list(region : Globals.regions, law_abiding : bool):
	var region_resource : Region = Globals.region_resources[region]
	for i in randi_range(5, 15):
		var random_choice = region_resource.pick_random_product(law_abiding)
		widgets_desired.push_back(random_choice)
		
