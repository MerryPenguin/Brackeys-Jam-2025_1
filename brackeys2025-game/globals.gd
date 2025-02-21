extends Node

# Store a few important node references for easy lookup
var current_level : Node2D
var current_player : CharacterBody2D
var current_hud : CanvasLayer
var products_in_demand : Array[products]

const grid_size : Vector2 = Vector2(16,16)
const building_scale : Vector2 = Vector2(6,6)

signal cash_changed

# Player Progress
var cash : int = 0 :
	set(v):
		cash = v
		cash_changed.emit(cash)
	get:
		return cash


var unlocked_recipes : Array = []


enum buildings { ORGANICS, INORGANICS, SPIRITUAL, AGGREGATOR, SUPER_AGGREGATOR}

var building_scenes : Dictionary = {
	buildings.ORGANICS : preload("res://Entities/factory_machines/organics_harvester_machine.tscn"),
	buildings.INORGANICS : preload("res://Entities/factory_machines/inorganics_harvester_machine.tscn"),
	buildings.SPIRITUAL : preload("res://Entities/factory_machines/spiritual_harvester_machine.tscn"),
	buildings.AGGREGATOR : preload("res://Entities/factory_machines/aggregator_combiner_machine.tscn"),
	buildings.SUPER_AGGREGATOR : preload("res://Entities/factory_machines/super_aggregator_combiner_machine.tscn"),
}



var unlocked_buildings : Array = [
	buildings.ORGANICS,
	buildings.AGGREGATOR,
]

enum products {
	STARCH, # ORGANIC
	ASH, # ORGANIC
	GEARS, # INORGANIC
	SPRINGS, # INORGANIC
	HOPES, # SPIRITUAL
	ANXIETY, # SPIRITUAL
	GUNPOWDER, # ASH + GEARS - for babies
	GRENADE, # PINEAPPLE + GEARS - for monkeys
	PINEAPPLE, # STARCH + HOPES - for time travellers
	BANANA, # STARCH + ASH - for monkeys
	EPISTEMOLOGY, # ANXIETY + GUNPOWDER - for time travellers
	ARTIFACT, # SPRINGS + HOPES - for time travellers
	PACIFIER, # ANXIETY + BANANA - for babies
	RAYGUN, # SPRINGS + GRENADE - for time travellers
	FRUITPHONE, # BANANA + EPISTEMOLOGY - for monkeys
	PARADOX, # FRUITPHONE + ANXIETY + EPISTEMOLOGY - anyone - win game (anxiety ending)
	SINGULARITY, # ARTIFACT + PINEAPPLE + FRUITPHONE - anyone - win game (hopeful ending)
}

const product_recipes : Dictionary = {
	products.STARCH : preload("res://Recipes/starch_recipe.tres"),
	products.ASH : preload("res://Recipes/ash_recipe.tres"),
	products.GEARS : preload("res://Recipes/gears_recipe.tres"),
	products.SPRINGS : preload("res://Recipes/springs_recipe.tres"),
	products.HOPES : preload( "res://Recipes/hopes_recipe.tres"),
	products.ANXIETY : preload("res://Recipes/anxiety_recipe.tres"),
	products.GUNPOWDER : preload("res://Recipes/gunpowder_recipe.tres"),
	products.GRENADE : preload("res://Recipes/grenade_recipe.tres"),
	products.PINEAPPLE : preload("res://Recipes/pineapple_recipe.tres"),
	products.BANANA : preload("res://Recipes/banana_recipe.tres"),
	products.EPISTEMOLOGY : preload("res://Recipes/epistemology_recipe.tres"),
	products.ARTIFACT : preload("res://Recipes/artifact_recipe.tres"),
	products.PACIFIER : preload("res://Recipes/pacifier_recipe.tres"),
	products.RAYGUN : preload("res://Recipes/raygun_recipe.tres"),
	products.FRUITPHONE : preload("res://Recipes/fruitphone_recipe.tres"),
	products.PARADOX : preload("res://Recipes/paradox_recipe.tres"),
	products.SINGULARITY : preload("res://Recipes/singularity_recipe.tres"),
}


func get_product_by_name(product_name):
	for product_num in products.values():
		if product_recipes[product_num].product_name == product_name:
			return product_num
