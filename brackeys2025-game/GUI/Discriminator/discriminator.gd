extends Control

enum states { UNDECIDED, APPROVED, DENIED }
var state : states = states.UNDECIDED

var customer # Could be RovingCustomer or VehiclePathFollower
signal approved
signal denied

func _ready():
	get_tree().paused = true
	
	$InstructionsPopupPanel.hide()
	

func activate(manifest : ProcurementManifest, incoming_customer): # include customer so we can callback to them and release them from their DETAINED state
	customer = incoming_customer
	#customer.state = customer.states.DETAINED # they can handle this themselves, I think
	populate_receipt(manifest)
	populate_order_form(manifest)
	populate_basket(manifest)
	populate_identity(manifest)
	connect_signals(incoming_customer)

func connect_signals(incoming_customer):
	if incoming_customer.has_method("_on_discriminator_approved"):
		approved.connect(incoming_customer._on_discriminator_approved)
	if incoming_customer.has_method("_on_discriminator_denied"):
		denied.connect(incoming_customer._on_discriminator_denied)

func populate_identity(manifest: ProcurementManifest):
	%PassportContainer.id = manifest.purchasing_agent.id
	%IDContainer.sex = manifest.purchasing_agent.sex
	%PassportContainer.affiliations = manifest.purchasing_agent.affiliation
	%IDContainer.education = manifest.purchasing_agent.education
	

func populate_order_form(manifest : ProcurementManifest):
	# fill it with random product icons
	var item_list = []
	item_list.append_array(manifest.widgets_desired) # Take this out later?
	item_list.append_array(manifest.items_purchased)
	item_list.append_array(manifest.items_stolen)
	var new_grid = GridContainer.new()
	new_grid.columns = 5
	%OrderForm.get_node("marker").add_child(new_grid)
	#new_grid.position = Vector2.ZERO
	for item in item_list:
		new_grid.add_child(generate_single_item(item))

func populate_basket(manifest: ProcurementManifest):
	var item_list = []
	item_list.append_array(manifest.items_purchased)
	item_list.append_array(manifest.items_stolen)
	var grid = %PurchasedItems
	for item in item_list:
		grid.add_child(generate_single_item(item))

func generate_single_item(product : Globals.products) -> TextureRect: 
	var new_texture_rect = TextureRect.new()
	new_texture_rect.custom_minimum_size = Vector2(32,32)
	new_texture_rect.size = Vector2(32,32)
	new_texture_rect.texture = Globals.product_recipes[product].icon
	new_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return new_texture_rect
	
	
func populate_receipt(manifest : ProcurementManifest):
	var receipt_tree : Tree = %Receipt.get_node("Tree")
	receipt_tree.columns = 2
	receipt_tree.set_column_clip_content(0, true)
	receipt_tree.set_column_clip_content(1, false)
	
	var root = receipt_tree.create_item()
	receipt_tree.hide_root = true
	var in_stock = receipt_tree.create_item(root)
	in_stock.set_text(0, "Item:")
	in_stock.set_text(1, "Paid")
	
	## Note: I couldn't get tree column clipping to work correctly in a timely fashion, so I won't bother showing out of stock items.
	#var out_of_stock = receipt_tree.create_item(root)
	#out_of_stock.set_text(0, "Out of Stock")
	#out_of_stock.set_text(1, "Out of Stock")

	create_pricelist(in_stock, manifest.items_purchased, true)
	#create_pricelist(out_of_stock, new_customer.widgets_desired, false)

func create_pricelist(tree_node : TreeItem, item_list : Array, show_price: bool = true):
	var receipt_tree : Tree = %Receipt.get_node("Tree")

	for item in item_list:
		var recipe = Globals.product_recipes[item]
		var row_entry = receipt_tree.create_item(tree_node)
		row_entry.set_text(0, recipe.product_name)

		if show_price:
			var cost = Utils.lookup_value(item)
			if cost == null or cost == 0:
				push_warning("price of " + recipe.product_name + " is not set correctly")
			row_entry.set_text(1, "$" + str(cost))


func _on_close_button_pressed() -> void:
	queue_free() # return to game. 
	# so far, we haven't paused it, but we may want to change that behaviour.
	


func _on_approve_button_pressed() -> void:
	if state == states.UNDECIDED:
		$AnimationPlayer.play("approve")
		state = states.APPROVED
		approved.emit()
		#if customer != null and is_instance_valid(customer):
			#customer.queue_free()

func _on_deny_button_pressed() -> void:
	if state == states.UNDECIDED:
		$AnimationPlayer.play("deny")
		state = states.DENIED
		denied.emit()
		#if customer != null and is_instance_valid(customer):
			#customer.queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ["approve", "deny"]:
		queue_free()


func _on_help_button_pressed() -> void:
	$InstructionsPopupPanel.popup_centered(Vector2(512, 384))
	


func _on_instructions_close_button_pressed() -> void:
	$InstructionsPopupPanel.hide()


func _on_tree_exiting() -> void:
	
	get_tree().paused = false


func _on_id_extents_gui_input(_event: InputEvent) -> void:
	pass # Replace with function body.
