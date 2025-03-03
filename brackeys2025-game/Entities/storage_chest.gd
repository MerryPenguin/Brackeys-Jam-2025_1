## Storage Chest is like an endpoint for products.
# Customers will come to these to look for products they want.

class_name StorageChest extends Node2D

@export var interval : float = 3.0
@export var region : Globals.regions = Globals.regions.AMERICAS

#@export var max_capacity : int = 24
#var items_stored : Array[FactoryProductWidget] # may not be optimal keeping all those objects around, could be a dictionary with names and quantities

var hovering : bool = false
@onready var storage : StorageComponent = $StorageComponent



func _ready():
	hide_hover_info()
	if has_node("IncomingVehicles"):
		var incoming_vehicles = get_node("IncomingVehicles")
		incoming_vehicles.activate(self, region, interval)
	
	
func hide_hover_info():
	$ItemCountLabel.hide()
	#$ConnectorNodes.hide()
	#$PopupInfo.hide()
	
func show_hover_info():
	$ItemCountLabel.show()
	$ConnectorNodes.show()
	update_popup_text()
	#$PopupInfo.show()


func update_popup_text():
	var textbox : TextEdit = %InventoryList
	textbox.text = storage.get_inventory_list()


func receive_product(widget):
	storage.receive_product(widget)
	$ItemCountLabel.text = str(storage.get_total_held())
	update_popup_text()
	$EmptyLabel.hide()

func sell_product(product_idx : Globals.products, buyer):
	if storage.has_product_num(product_idx):
		storage.give_product(product_idx, buyer)

	
func sell(product_name : StringName, buyer): # Buyer could be RovingCustomer or VehiclePathFollower
	# most likely selling a product to a customer
	# remove widget from inventory, give it to customer
	if storage.has_product_named(product_name):
		storage.give_product_by_name(product_name, buyer)
		#Globals.cash += lookup_value(product_name)

func sell_oldest_product(buyer):
	if storage.get_total_held() > 0:
		storage.give_product(storage.products_stored[0], buyer)

func lookup_value(product_name) -> int:
	for product_num in Globals.products.values():
		var product_recipe : ProductWidgetRecipe = Globals.product_recipes[product_num]
		if product_recipe.product_name == product_name:
			var sale_price = product_recipe.default_sale_price
			if Globals.products_in_demand.has(product_num):
				sale_price *= 2.0
			return sale_price
	return 0

func get_customer_count():
	var count = 0
	for body in $CustomerInteractionArea.get_overlapping_bodies():
		if body is RovingCustomer:
			count += 1
	return count


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
		
