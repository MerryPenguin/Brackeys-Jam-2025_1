## Factory Floor is your base level scene
# holds machines, conveyor belts, players, customers, etc.
# should have a couple of helper functions for instantiating temporary nodes into the correct containers


extends Node2D


func _init():
	Globals.current_level = self

func spawn_widget_on_floor(widget : FactoryProductWidget, location):
	$LooseWidgets.add_child(widget)
	widget.global_position = location

func spawn_conveyor_belt(conveyor_belt : ConveyorBelt):
	$Transporters.add_child(conveyor_belt)
