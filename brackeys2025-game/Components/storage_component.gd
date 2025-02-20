class_name StorageComponent extends Node2D

@export var max_capacity : int = 24
@export var tooltip_disabled : bool = false
var items_stored : Array[FactoryProductWidget] # may not be optimal keeping all those objects around, could be a dictionary with names and quantities

var hovering : bool = false

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

func erase_product(product_index : Globals.products):
	for widget in items_stored:
		if widget.recipe.product_name == Globals.product_recipes[product_index].product_name:
			items_stored.erase(widget)
			return

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
	


func _on_hover_area_mouse_entered() -> void:
	hovering = true
	$HoverTimer.set_wait_time(0.2)
	$HoverTimer.start()

func _on_hover_area_mouse_exited() -> void:
	hovering = false
	$HoverTimer.set_wait_time(1.0)
	$HoverTimer.start()

func show_popup_info():
	if tooltip_disabled:
		return
	%TooltipInfo.text = get_inventory_list()
	$PanelContainer.show()
	
func hide_popup_info():
	$PanelContainer.hide()

func _on_hover_timer_timeout() -> void:
	if hovering:
		show_popup_info()
	else:
		hide_popup_info()
