extends Button

@export var product : Globals.products 
var recipe

func _ready():
	icon = Globals.product_recipes[product].icon
	recipe = Globals.product_recipes[product]
