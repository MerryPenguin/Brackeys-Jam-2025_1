class_name ProductWidgetRecipe extends Resource
# Note about resources: they're re-used / shared between scenes.
# Therefore, if you edit one, it'll change on all.
@export var product_name : StringName = ""
@export var required_inputs : Array[RequirementsManifest] = []

@export var production_time : float = 1.5 # time to convert requirements into output
#const output_widget : PackedScene = preload("res://Entities/factory_products/factory_product_widget.tscn")
@export var icon : Texture2D

# helper var to describe which type of machines can produce this.
enum recipe_types { ORGANIC, INORGANIC, SPIRITUAL, AGGREGATED }
@export var recipe_type : recipe_types

@export var default_sale_price : int = 10
# Might want to have market trends, supply/demand, which affect actual sale prices
