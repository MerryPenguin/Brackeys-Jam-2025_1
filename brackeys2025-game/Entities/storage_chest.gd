## Storage Chest is like an endpoint for products.
# Customers will come to these to look for products they want.

class_name StorageChest extends Node2D

@export var max_capacity : int = 24
var items_stored : Array[FactoryProductWidget] # may not be optimal keeping all those objects around, could be a dictionary with names and quantities


func receive_product(widget):
	items_stored.push_back(widget)
	$ItemCountLabel.text = str(items_stored.size())
	
func is_full():
	return items_stored.size() >= max_capacity

	
func sell(widget_name : StringName):
	# most likely selling a product to a customer
	
	pass
	
