## Storage Chest is like an endpoint for products.
# Customers will come to these to look for products they want.

class_name StorageChest extends Node2D

@export var max_capacity : int = 24
var items_stored : Array[FactoryProductWidget] # may not be optimal keeping all those objects around, could be a dictionary with names and quantities

var hovering : bool = false

func _ready():
	hide_hover_info()
	
	
func hide_hover_info():
	$ItemCountLabel.hide()
	$ConnectorNodes.hide()
	$PopupInfo.hide()
	
func show_hover_info():
	$ItemCountLabel.show()
	$ConnectorNodes.show()
	update_popup_text()
	$PopupInfo.show()


func update_popup_text():
	var textbox : TextEdit = %InventoryList
	textbox.text = ""
	var product_counts = widget_array_to_dictionary(items_stored)
	for product_type in product_counts.keys():
		textbox.text += "\n" + product_type+ ": " + str(product_counts[product_type])

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
	$ItemCountLabel.text = str(items_stored.size())
	update_popup_text()
	
func is_full():
	return items_stored.size() >= max_capacity

	
func sell(widget_name : StringName):
	# most likely selling a product to a customer
	
	pass
	


func _on_mouse_detection_area_mouse_entered() -> void:
	$HoverTimer.set_wait_time(0.2)
	hovering = true
	$HoverTimer.start()
	


func _on_mouse_detection_area_mouse_exited() -> void:
	$HoverTimer.set_wait_time(2.0)
	hovering = false
	$HoverTimer.start()




func _on_hover_timer_timeout() -> void:
	if hovering:
		show_hover_info()
	else:
		hide_hover_info()
		
