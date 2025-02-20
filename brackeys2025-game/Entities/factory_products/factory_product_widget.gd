## This is the item on the conveyor belt.
# could be raw material, upgraded material, parts, products, whatever
# factories use these as inputs to convert them to other product widgets
# customers want them
# they can go in inventory or storage chests
# they can pile up on assembly lines

# note: This may get shuffled around the scene tree a bit, so at any given time it might not have an owner.

class_name FactoryProductWidget extends Node2D

@export var market_value : float = 25 # dollars

var origin : Node2D
var destination : Node2D
var package : PathFollow2D # the conveyor belt assembly.
var recipe : ProductWidgetRecipe # so we don't need a unique scene for each product? We can just refer to the recipe.


func _on_area_2d_body_entered(body: Node2D) -> void:
	if package != null:
		return # you're on a conveyor belt, let the package handle delivery
	elif body is RovingCustomer:
		return # Customers like to carry widgets
		
	elif body != origin: # This was intended for the player to pick things up.
		if body.has_method("receive_product"):
			get_parent().remove_child(self) # detach from conveyor belt or floor
			body.receive_product(self)
			if package != null:
				package.release_contents()

func activate(new_recipe : ProductWidgetRecipe):
	recipe = new_recipe
	$Sprite2D.texture = new_recipe.icon
	var tex_size = new_recipe.icon.get_size()
	var desired_size = Vector2(32,32)
	$Sprite2D.scale = desired_size / tex_size
