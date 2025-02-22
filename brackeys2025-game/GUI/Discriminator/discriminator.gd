extends Control

enum states { UNDECIDED, APPROVED, DENIED }
var state : states = states.UNDECIDED

var customer : RovingCustomer

func _ready():
	$InstructionsPopupPanel.hide()
	

func activate(new_customer : RovingCustomer):
	customer = new_customer
	customer.state = customer.states.DETAINED
	populate_receipt(customer)
	populate_order_form(customer)
	populate_basket(customer)

func populate_order_form(new_customer : RovingCustomer):
	# fill it with random product icons
	var item_list = []
	item_list.append_array(new_customer.widgets_desired) # Take this out later?
	item_list.append_array(new_customer.items_purchased)
	item_list.append_array(new_customer.items_stolen)
	var new_grid = GridContainer.new()
	new_grid.columns = 2
	%OrderForm.get_node("marker").add_child(new_grid)
	#new_grid.position = Vector2.ZERO
	for item in item_list:
		new_grid.add_child(generate_single_item(item))

func populate_basket(new_customer: RovingCustomer):
	var item_list = []
	item_list.append_array(new_customer.items_purchased)
	item_list.append_array(new_customer.items_stolen)
	var new_grid = GridContainer.new()
	new_grid.columns = 2
	%Basket.add_child(new_grid)
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
	
	
func populate_receipt(new_customer : RovingCustomer):
	var receipt_tree : Tree = %Receipt.get_node("Tree")
	receipt_tree.columns = 2
	var root = receipt_tree.create_item()
	receipt_tree.hide_root = true
	var header = receipt_tree.create_item(root)
	header.set_text(0, "Item:")
	header.set_text(1, "Price Paid")
	
	for item in new_customer.items_purchased:
		var recipe = Globals.product_recipes[item]
		var cost = Utils.lookup_value(item)
		if cost == null or cost == 0:
			push_warning("price of " + recipe.product_name + " is not set correctly")
		var row_entry = receipt_tree.create_item(root)
		row_entry.set_text(0, recipe.product_name)
		row_entry.set_text(1, "$" + str(cost))


func _on_close_button_pressed() -> void:
	queue_free() # return to game. 
	# so far, we haven't paused it, but we may want to change that behaviour.
	


func _on_approve_button_pressed() -> void:
	if state == states.UNDECIDED:
		$AnimationPlayer.play("approve")
		state = states.APPROVED
		customer.queue_free()

func _on_deny_button_pressed() -> void:
	if state == states.UNDECIDED:
		$AnimationPlayer.play("deny")
		state = states.DENIED
		customer.queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["approve", "deny"]:
		queue_free()


func _on_help_button_pressed() -> void:
	$InstructionsPopupPanel.popup_centered(Vector2(512, 384))
	


func _on_instructions_close_button_pressed() -> void:
	$InstructionsPopupPanel.hide()
