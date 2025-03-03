## Factory Machine
# take inputs, add time, make outputs

class_name FactoryMachine extends Node2D


@onready var connectors : Node2D = $Connectors

enum types { HARVESTER, AGGREGATOR }
@export var type = types.HARVESTER
@export var short_name = ""

@export var unlocked_recipes : Array[ProductWidgetRecipe]
@export var current_recipe : ProductWidgetRecipe


@onready var storage : StorageComponent = $StorageComponent
@onready var production_timer : Timer = $ProductionTimer


signal input_node_connected # for tutorial win condition only
signal recipe_changed
signal winning_product_produced(product)

func _ready():
	connectors.hide()
	remove_unneeded_connectors()
	#setup_inventory_dict()
	$PlacementNoise.play()
	recipe_changed.connect($InteractionButton._on_factory_machine_recipe_changed)
	var current_level = Globals.current_level
	if current_level and current_level.has_method("_on_winning_item_produced"):
		winning_product_produced.connect(current_level._on_winning_item_produced)
	if current_recipe != null:
		recipe_changed.emit(current_recipe)
	setup_timer()

func remove_unneeded_connectors():
	if type == types.HARVESTER:
		%InputNode.queue_free()

func setup_timer():
	var timer : Timer = $ProductionTimer
	if current_recipe:
		timer.set_wait_time(current_recipe.production_time)
	else:
		timer.set_wait_time(1.0)
	timer.start()
	
func get_icon():
	return %Sprite2D.texture.duplicate()

func get_icon_region():
	return %Sprite2D.texture.region
	

func _on_mouse_detection_area_mouse_entered() -> void:
	connectors.show()

func _on_mouse_detection_area_mouse_exited() -> void:
	connectors.hide()

func receive_product(product_idx : Globals.products):
	storage.receive_product(product_idx)
	
	#for manifest : RequirementsManifest in current_recipe.required_inputs:
		#if not widget or not widget.recipe:
			#push_warning(widget.name, " has no recipe?")
		#if manifest.get_widget_name() == widget.recipe.product_name:
			#if not manifest.is_full():
				#manifest.add(1)


func is_full(_item_name : String):
	return storage.is_full()


func requirements_met(recipe : ProductWidgetRecipe) -> bool:
	if recipe == null:
		return false
	if recipe.required_inputs.is_empty():
		return true # Harvesters don't need anything
	else:
		var requirements_count = recipe.required_inputs.size()
		var products_found = 0
		for product : Globals.products in recipe.required_inputs:

			var requirement = Globals.product_recipes[product] # [recipe, quantity]
			if storage.has_product_named(requirement.product_name):
				products_found += 1
		return products_found >= requirements_count
	


func produce(recipe : ProductWidgetRecipe):
	#var widget_scene = preload("res://Entities/factory_products/factory_product_widget.tscn")
	#if widget_scene == null:
		#push_warning(self.name, ": factory_machine has no widget_scene")
		#push_warning(recipe)
		#breakpoint
		#return # No recipe. Do nothing

	# instantiate one of these onto a conveyor belt, or on the floor for the player if no conveyor belt
	if is_output_connected():
		#var new_widget : FactoryProductWidget = widget_scene.instantiate()
		#new_widget.activate(recipe)
		check_win_conditions(recipe)
		%OutputNode.receive_product(Globals.get_product_by_name(recipe.product_name))
		for requirement in recipe.required_inputs:
			storage.erase_product(requirement)
	else:  # no conveyor belt
		#drop_on_floor()
		pass # player has no means to pick these up, so we removed it

func check_win_conditions(recipe : ProductWidgetRecipe):
	var product = Globals.get_product_by_name(recipe.product_name)
	if product in Globals.current_level.winning_products:
		winning_product_produced.emit(recipe.product_name)

func is_output_connected():
	if %OutputNode.conveyor_belt != null:
		return true
	else:
		return false



func get_root_node_name(packed_scene : PackedScene):
	return packed_scene.get_state().get_node_name(0)

func get_missing_requirements(recipe : ProductWidgetRecipe) -> PackedStringArray:
	var missing : PackedStringArray = []
	for required_product : Globals.products in recipe.required_inputs:
		var requirement = Globals.product_recipes[required_product]
		if storage.has_product_named(requirement.product_name):
			missing.push_back(requirement.product_name)
	return missing

func check_all_recipes_for_requirements() -> ProductWidgetRecipe:
	for recipe_num in Globals.products.values():
		var recipe = Globals.product_recipes[recipe_num]
		if recipe.recipe_type == recipe.recipe_types.AGGREGATED and requirements_met(recipe):
			return recipe
	return null


func destruct():
	
	$DestructionNoise.spawn() # plays independent of this node, which is about to leave the scene
	for connector in $Connectors.get_children():
		if connector.conveyor_belt:
			connector.conveyor_belt.destruct()
	remove_conveyors_attached_to_me()
	remove_connectors()
	$AnimationPlayer.play("destruct")


func remove_connectors(): # prevent people drawing new conveyor belts during explosions.
	for node in $Connectors.get_children():
		if node is Area2D:
			# Might need to call deferred physics states
			node.set_deferred("monitoring", false)
			node.set_deferred("monitorable", false)
			

func remove_conveyors_attached_to_me():
	var belts = get_tree().get_nodes_in_group("conveyor_belts")
	for belt in belts:
		if belt.destination == %InputNode:
			belt.destruct()

func _on_production_timer_timeout() -> void:
	# consume inventory, release product
	var valid_recipe = check_all_recipes_for_requirements()
	if valid_recipe:
		if current_recipe != valid_recipe:
			# New recipe
			current_recipe = valid_recipe
		recipe_changed.emit(valid_recipe)
		# should also change the icon on the button
	if current_recipe and requirements_met(current_recipe):
		produce(current_recipe)
		$ProductionLabel.text = ""
	else:
		$ProductionLabel.text = "!!!"
	$ProductionTimer.start()


func _on_interaction_button_recipe_changed(recipe: Variant) -> void:
	current_recipe = recipe # save it so we can pass it on the the produced widgets

func _on_connector_node_connected(node):
	if node.type == node.types.INPUT:
		# for tutorial level win condition
		input_node_connected.emit()
		$BeltConnectedNoise.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "destruct":
		call_deferred("queue_free")
