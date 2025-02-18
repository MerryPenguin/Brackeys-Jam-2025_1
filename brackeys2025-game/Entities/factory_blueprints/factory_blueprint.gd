## ghost impression of a factory
## spawns after the player clicks a factory placement button
## follows the cursor until mouse click
## then spawns the appropriate factory


class_name FactoryBlueprint extends Node2D

@export var factory_scene : PackedScene

enum states { DRAGGING, DROPPED }
var state = states.DRAGGING

func _ready():
	pass
	
func _process(delta):
	follow_mouse(delta)
	if Input.is_action_just_pressed("interact"):
		spawn_factory()
		queue_free()

func follow_mouse(_delta):
	global_position = get_global_mouse_position()
	
func spawn_factory():
	var new_factory = factory_scene.instantiate()
	Globals.current_level.spawn_factory(new_factory, get_global_mouse_position() )
