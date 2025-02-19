class_name StorageComponent extends Node

@export var max_capacity : int = 24
var items_stored : Array[FactoryProductWidget] # may not be optimal keeping all those objects around, could be a dictionary with names and quantities


func widget_array_to_dictionary(widgets_array):
	var product_counts := {}
	for widget in widgets_array:
		var product_name = widget.recipe.product_name
		if product_name in product_counts:
			product_counts[product_name] += 1
		else:
			product_counts[product_name] = 1
	return product_counts

func receive_product(widget):
	items_stored.push_back(widget)
	#$ItemCountLabel.text = str(items_stored.size())
	#update_popup_text()
	

func has_product_named(product_name, amount_required : int = 1) -> bool:
	var count = 0
	for item in items_stored:
		if item.recipe.product_name == product_name:
			count += 1
	return count >= amount_required


func give_product_by_name(product_name, recipient):
	for item in items_stored:
		if item.recipe.product_name == product_name:
			if recipient.has_method("receive_product"):
				recipient.receive_product(item)
				items_stored.erase(item)
				return
	
func give_product(widget, recipient):
	if widget in items_stored:
		if recipient.has_method("receive_product"):
			recipient.receive_product(widget)
			items_stored.erase(widget)

func get_inventory_list() -> String:
	var text = ""
	var product_counts = widget_array_to_dictionary(items_stored)
	for product_type in product_counts.keys():
		text += "\n" + product_type+ ": " + str(product_counts[product_type])
	return text

func get_total_held() -> int:
	return items_stored.size()

func is_full():
	return items_stored.size() >= max_capacity
	
