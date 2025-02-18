extends Node

# Store a few important node references for easy lookup
var current_level : Node2D
var current_player : CharacterBody2D

var grid_size : Vector2 = Vector2(64,64)


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

var product_recipes : Dictionary = {
	products.PINEAPPLE : preload("res://Recipes/pineapple_recipe.tres"),
	products.GRENADE : preload("res://Recipes/grenade_recipe.tres"),
	products.GEARS : preload("res://Recipes/gears_recipe.tres"),
}
