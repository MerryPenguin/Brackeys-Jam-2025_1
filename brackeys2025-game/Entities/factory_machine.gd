## Factory Machine
# take inputs, add time, make outputs

extends Node2D

@export var required_inputs : Array[RequirementsManifest] = []

@export var production_time : float = 10.0 # time to convert requirements into output
@export var output_widget : PackedScene # NOTE: It might be smarter to use paths instead of packed scenes. we'll see.

@onready var connectors : Node2D = $Connectors

#var inventory: Dictionary[String, Dictionary] = {} # name: {scene, held, max}
# We'll store the currently_held value inside the specific manifest in required_inputs

func _ready():
	connectors.hide()
	#setup_inventory_dict()
	$ProductionTimer.set_wait_time(production_time)
	$ProductionTimer.start()
	

#func setup_inventory_dict():
	#var unique_inputs = []
	#for input in required_inputs:
		#if not unique_inputs.has(input):
			#unique_inputs.push_back(input)
	#for item : PackedScene in unique_inputs:
		#var ref_item = item.instantiate()
		#inventory[ref_item.name] = {"scene": item, "held":0, "capacity":10}
		#ref_item.queue_free()
			
	
func _on_mouse_detection_area_mouse_entered() -> void:
	connectors.show()

func _on_mouse_detection_area_mouse_exited() -> void:
	connectors.hide()

func receive_product(widget : FactoryProductWidget):
	for manifest : RequirementsManifest in required_inputs:
		if manifest.get_widget_name() == widget.name:
			if not manifest.is_full():
				manifest.add(1)
			
	
		
func is_full(item_name : String):
	#return inventory[item_name]["held"] >= inventory[item_name]["capacity"]
	for manifest in required_inputs:
		if manifest.get_widget_name() == item_name:
			return manifest.max_capacity >= manifest.currently_held
	return false # couldn't find item name in required_inputs

func requirements_met():
	for manifest in required_inputs:
		if not manifest.requirements_met():
			return false
	return true

func produce(widget_scene : PackedScene):
	# instantiate one of these onto a conveyor belt
	print("Produced: ", get_root_node_name(widget_scene))
	
func get_root_node_name(packed_scene : PackedScene):
	return packed_scene.get_state().get_node_name(0)

func _on_production_timer_timeout() -> void:
	# consume inventory, release product
	if requirements_met():
		produce(output_widget)
	else:
		print("failed to meet requirements for ", get_root_node_name(output_widget))
	$ProductionTimer.start()
