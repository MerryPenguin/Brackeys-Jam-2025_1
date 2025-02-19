## Factory Machine
# take inputs, add time, make outputs

class_name FactoryMachine extends Node2D

#@export var required_inputs : Array[RequirementsManifest] = []

#@export var production_time : float = 10.0 # time to convert requirements into output
#@export var output_widget : PackedScene # NOTE: It might be smarter to use paths instead of packed scenes. we'll see.

@onready var connectors : Node2D = $Connectors

@export var unlocked_recipes : Array[ProductWidgetRecipe]
@export var current_recipe : ProductWidgetRecipe

@onready var storage : StorageComponent = $StorageComponent
@onready var production_timer : Timer = $ProductionTimer

signal input_node_connected # for tutorial win condition only
signal recipe_changed

func _ready():
	connectors.hide()
	#setup_inventory_dict()
	$PlacementNoise.play()
	recipe_changed.connect($InteractionButton._on_factory_machine_recipe_changed)
	set_first_recipe()
	$ProductionTimer.set_wait_time(current_recipe.production_time)
	$ProductionTimer.start()

func set_first_recipe():
	if unlocked_recipes.is_empty():
		push_warning(self.name, " factory_machine has no unlocked recipes")
		return
	current_recipe = unlocked_recipes[0]
	recipe_changed.emit(current_recipe)
	

func _on_mouse_detection_area_mouse_entered() -> void:
	connectors.show()

func _on_mouse_detection_area_mouse_exited() -> void:
	connectors.hide()

func receive_product(widget : FactoryProductWidget):
	storage.receive_product(widget)
	
	#for manifest : RequirementsManifest in current_recipe.required_inputs:
		#if not widget or not widget.recipe:
			#push_warning(widget.name, " has no recipe?")
		#if manifest.get_widget_name() == widget.recipe.product_name:
			#if not manifest.is_full():
				#manifest.add(1)


func is_full(_item_name : String):
	return storage.is_full()


func requirements_met(recipe : ProductWidgetRecipe):
	if recipe.required_inputs.is_empty():
		return true
	else:
		for manifest : RequirementsManifest in recipe.required_inputs:
			var requirement = manifest.get_requirements() # [recipe, quantity]
			if storage.has_product_named(requirement[0].product_name, requirement[1]):
				return true
			else:
				return false


func produce():
	var widget_scene = preload("res://Entities/factory_products/factory_product_widget.tscn")
	if widget_scene == null:
		push_warning(self.name, ": factory_machine has no widget_scene")
		push_warning(current_recipe)
		breakpoint
		return # No recipe. Do nothing

	# instantiate one of these onto a conveyor belt, or on the floor for the player if no conveyor belt
	if is_output_connected():
		var new_widget : FactoryProductWidget = widget_scene.instantiate()
		new_widget.activate(current_recipe)
		%OutputNode.receive_product(new_widget)
	else:  # no conveyor belt
		#drop_on_floor()
		pass # player has no means to pick these up, so we removed it

func is_output_connected():
	if %OutputNode.conveyor_belt != null:
		return true
	else:
		return false



func drop_on_floor(widget : FactoryProductWidget):
	var scatter_vec = Vector2(randi_range(-32, 32), randi_range(-32,32))
	var location = %OutputNode.global_position + scatter_vec
	
	Globals.current_level.spawn_widget_on_floor(widget, location)

func get_root_node_name(packed_scene : PackedScene):
	return packed_scene.get_state().get_node_name(0)

func get_missing_requirements(recipe : ProductWidgetRecipe) -> PackedStringArray:
	var missing : PackedStringArray = []
	for manifest : RequirementsManifest in recipe.required_inputs:
		var requirement = manifest.get_requirements() # [ recipe, quantity]
		if storage.has_product_named(requirement[0].product_name, requirement[1]):
			missing.push_back(manifest.get_widget_name())
	return missing

func check_all_recipes_for_requirements() -> ProductWidgetRecipe:
	for recipe_num in Globals.products.values():
		var recipe = Globals.product_recipes[recipe_num]
		if recipe.recipe_type == recipe.recipe_types.AGGREGATED and requirements_met(recipe):
			return recipe
	return null


func _on_production_timer_timeout() -> void:
	# consume inventory, release product
	var valid_recipe = check_all_recipes_for_requirements()
	if valid_recipe:
		current_recipe = valid_recipe
		recipe_changed.emit(valid_recipe)
		# should also change the icon on the button
	if requirements_met(current_recipe):
		produce()
		$MissingRequirementsLabel.text = ""
	else:
		$MissingRequirementsLabel.text = "!!!"
	$ProductionTimer.start()


func _on_interaction_button_recipe_changed(recipe: Variant) -> void:
	# update required inputs, production time and outputs
	#required_inputs = recipe.required_inputs
	#production_time = recipe.production_time
	#output_widget = recipe.output_widget
	current_recipe = recipe # save it so we can pass it on the the produced widgets

func _on_connector_node_connected(node):
	if node.type == node.types.INPUT:
		# for tutorial level win condition
		input_node_connected.emit()
