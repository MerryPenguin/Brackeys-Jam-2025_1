## This is the item on the conveyor belt.
# could be raw material, upgraded material, parts, products, whatever
# factories use these as inputs to convert them to other product widgets
# customers want them
# they can go in inventory or storage chests
# they can pile up on assembly lines

# note: This may get shuffled around the scene tree a bit, so at any given time it might not have an owner.

class_name FactoryProductWidget extends Node2D

var origin : Node2D
var destination : Node2D
var package : PathFollow2D # the conveyor belt assembly.



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != origin:
		if body.has_method("receive_product"):
			body.receive_product(self)
			package.release_contents()
