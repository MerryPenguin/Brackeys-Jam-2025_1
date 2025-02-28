class_name StorageComponent extends Node2D

@export var max_capacity : int = 24
@export var tooltip_disabled : bool = false
#var items_stored : Array[FactoryProductWidget] # may not be optimal keeping all those objects around, could be a dictionary with names and quantities
var products_stored : Array[Globals.products] # no need to hold the whole object

var hovering : bool = false

func _ready():
	hide_popup_info()

func products_array_to_dictionary(products_array : Array[Globals.products]):
	var product_counts := {}
	for product_idx in products_array:
		var product_name = Globals.product_recipes[product_idx].product_name
		if product_name in product_counts:
			product_counts[product_name] += 1
		else:
			product_counts[product_name] = 1
	return product_counts

func receive_product(product_idx : Globals.products):
	products_stored.push_back(product_idx)
	
	

func has_product_obj(product_obj : FactoryProductWidget) -> bool:
	var product_idx = Globals.get_product_by_name(product_obj.recipe.product_name)
	return has_product_num(product_idx)

func has_product_num(product : Globals.products) -> bool:
	for product_idx in products_stored:
		if product_idx == product:
			return true
	return false

func has_product_for_recipe(recipe: ProductWidgetRecipe) -> bool:
	var product_idx = Globals.get_product_by_name(recipe.product_name)
	return has_product_num(product_idx)


func has_product_named(product_name) -> bool:
	var product_idx = Globals.get_product_by_name(product_name)
	return has_product_num(product_idx)

func give_product_by_name(product_name, recipient):
	#for item : FactoryProductWidget in items_stored:
	for product_idx in products_stored:
		if Globals.product_recipes[product_idx].product_name == product_name:
			if recipient.has_method("receive_product"):
				recipient.receive_product(product_idx)
				products_stored.erase(product_idx)
				return

func spawn_product_obj(recipe) -> FactoryProductWidget: # might not need this
	var new_product_obj = preload("res://Entities/factory_products/factory_product_widget.tscn").instantiate()
	new_product_obj.activate(recipe)
	return new_product_obj
	
	
func give_product(product_idx : Globals.products, recipient):
	if product_idx in products_stored:
		if recipient.has_method("receive_product"):
			recipient.receive_product(product_idx)
			products_stored.erase(product_idx)

func erase_product(product_index : Globals.products):
	products_stored.erase(product_index)


func get_inventory_list() -> String:
	var text = "Stored Products:"
	var product_counts = products_array_to_dictionary(products_stored)
	for product_type in product_counts.keys():
		text += "\n" + product_type+ ": " + str(product_counts[product_type])
	return text

func get_total_held() -> int:
	return products_stored.size()

func is_full():
	return products_stored.size() >= max_capacity
	


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
