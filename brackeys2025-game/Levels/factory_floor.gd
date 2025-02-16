## Factory Floor is your base level scene
# holds machines, conveyor belts, players, customers, etc.
# should have a couple of helper functions for instantiating temporary nodes into the correct containers


extends Node2D


func _init():
	Globals.current_level = self

func spawn_widget_on_floor(widget_scene : PackedScene, location):
	var new_widget = widget_scene.instantiate()
	$LooseWidgets.add_child(new_widget)
	new_widget.global_position = location
