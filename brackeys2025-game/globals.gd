extends Node

# Store a few important node references for easy lookup
var current_level : Node2D
var current_player : CharacterBody2D

var grid_size : Vector2 = Vector2(64,64)


enum products {
	PINEAPPLE,
	GRENADE
}

var product_scenes = {
	products.PINEAPPLE : preload("res://Entities/factory_products/pineapple.tscn"),
	products.GRENADE : preload("res://Entities/factory_products/grenade.tscn"),
}
