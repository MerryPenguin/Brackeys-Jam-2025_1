## Storage Chest is like an endpoint for products.
# Customers will come to these to look for products they want.

class_name StorageChest extends Node2D

@export var max_capacity : int = 24
var items_stored : Array[FactoryProductWidget]


func receive_product(widget):
	items_stored.push_back(widget)
	$ItemCountLabel.text = str(items_stored.size())
	
func is_full():
	return items_stored.size() >= max_capacity
