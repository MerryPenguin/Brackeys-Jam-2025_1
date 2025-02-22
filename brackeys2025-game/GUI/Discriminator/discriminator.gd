extends Control

func _ready():
	pass
	

func activate(customer : RovingCustomer):
	customer.state == customer.states.DETAINED
	populate_order_form(customer)

func populate_order_form(customer : RovingCustomer):
	# fill it with random product icons
	var item_list = []
	item_list.append_array(customer.widgets_desired) # Take this out later?
	item_list.append_array(customer.items_purchased)
	item_list.append_array(customer.items_stolen)
	var new_grid = GridContainer.new()
	new_grid.columns = 2
	%OrderForm.get_node("marker").add_child(new_grid)
	#new_grid.position = Vector2.ZERO
	for item in item_list:
		new_grid.add_child(generate_single_item(item))

func generate_single_item(product : Globals.products) -> TextureRect: 
	var new_texture_rect = TextureRect.new()
	new_texture_rect.custom_minimum_size = Vector2(32,32)
	new_texture_rect.size = Vector2(32,32)
	new_texture_rect.texture = Globals.product_recipes[product].icon
	new_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return new_texture_rect
	
	
func populate_receipt(customer : RovingCustomer):
	var receipt_tree : Tree = $PanelContainer/Scroll/Tree
	var root = receipt_tree.create_item()
	receipt_tree.hide_root = true
	var child1 = receipt_tree.create_item(root)
	var child2 = receipt_tree.create_item(root)
	var subchild1 = receipt_tree.create_item(child1)
	subchild1.set_text(0, "Subchild1")


func _on_close_button_pressed() -> void:
	queue_free() # return to game. 
	# so far, we haven't paused it, but we may want to change that behaviour.
	
