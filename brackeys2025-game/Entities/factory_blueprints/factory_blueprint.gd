## ghost impression of a factory
## spawns after the player clicks a factory placement button
## follows the cursor until mouse click
## then spawns the appropriate factory


class_name FactoryBlueprint extends Node2D


@export var factory_scene : PackedScene

enum states { DRAGGING, DROPPED }
var state = states.DRAGGING

func _ready():
	#$SpawnNoise.play()
	# was conflicting with button press
	pass
	
func _process(delta):
	follow_mouse(delta)
	if Input.is_action_just_pressed("interact") and location_is_valid(global_position):
		get_viewport().set_input_as_handled()
		spawn_factory(global_position)
		queue_free()
		

func follow_mouse(_delta):
	var mouse_pos = get_global_mouse_position()
	var adjusted_pos = mouse_pos.snapped(Globals.grid_size * Globals.building_scale)
	if Config.get_config("GameSettings", "FactoriesSnapToGrid") == true:
		global_position = adjusted_pos
	else:
		global_position = mouse_pos

func location_is_valid(_location):
	# don't need location, we're using an Area2D detector
	var valid = true
	var possible_factories = $FactoryDetector.get_overlapping_bodies()
	if not possible_factories.is_empty():
		for body in possible_factories:
			if body.owner is FactoryMachine:
				valid = false
	return valid
	
func spawn_factory(location):
	if location_is_valid(location):
		var new_factory = factory_scene.instantiate()
		Globals.current_level.spawn_factory(new_factory, location )
	
