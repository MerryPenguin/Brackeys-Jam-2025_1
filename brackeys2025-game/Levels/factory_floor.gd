## Factory Floor is your base level scene
# holds machines, conveyor belts, players, customers, etc.
# should have a couple of helper functions for instantiating temporary nodes into the correct containers


class_name FactoryFloor extends Node2D


func _init():
	Globals.current_level = self

func _ready():
	validate_requirements()
	
func validate_requirements():
	for node_name in ["LooseWidgets", "Transporters", "Customers", "Machines"]:
		if not has_node(node_name):
			var new_node = Node2D.new()
			add_child(new_node)
			new_node.name = node_name

func spawn_widget_on_floor(widget : FactoryProductWidget, location):
	$LooseWidgets.add_child(widget)
	widget.global_position = location

func spawn_conveyor_belt(conveyor_belt : ConveyorBelt):
	$Transporters.add_child(conveyor_belt)

func spawn_customer(customer, location):
	$Customers.add_child(customer)
	customer.global_position = location

func spawn_factory(factory : FactoryMachine, location : Vector2):
	$Machines.add_child(factory)
	factory.global_position = location
	
func show_level_won_overlay(text):
	var level_won_overlay = preload("res://GUI/maaack_template/scenes/overlaid_menus/level_won_menu.tscn").instantiate()	
	level_won_overlay.text = text
	add_sibling(level_won_overlay)
	level_won_overlay.continue_pressed.connect(_on_next_level_requested)

func _on_next_level_requested():
	# TODO: This needs to emit something to a level manager from Maaack's template.
	# so the system knows which levels are complete.
	GameState.set_current_level(1)
	SceneLoader.load_scene("res://Levels/factory_floor.tscn")
