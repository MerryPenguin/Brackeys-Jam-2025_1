class_name ConnectorNode extends Area2D

enum types { INPUT, OUTPUT }
@export var type : types = types.INPUT

enum states { IDLE, DRAWING }
var state : states = states.IDLE

var connected : bool = false
var hovering : bool = false

var conveyor_belt : ConveyorBelt
var factory_machine : FactoryMachine

func _ready():
	$Label.text = types.keys()[type].capitalize()
	if owner is FactoryMachine:
		factory_machine = owner

func _process(_delta):
	match type:
		types.OUTPUT:
			if state == states.IDLE and hovering == true:
				if Input.is_action_just_pressed("interact"):
					begin_drawing()
			elif state == states.DRAWING and Input.is_action_just_released("interact"):
				stop_drawing()
		types.INPUT:
			pass # don't do anything with mouse clicks


func begin_drawing():
	state = states.DRAWING
	var new_conveyor = preload("res://Entities/Connectors/conveyor_belt.tscn").instantiate()
	Globals.current_level.spawn_conveyor_belt(new_conveyor)
	new_conveyor.global_position = Vector2.ZERO
	new_conveyor.activate(self)
	conveyor_belt = new_conveyor

func stop_drawing():
	# conveyor belts handle their own stop_drawing()
	state = states.IDLE

func _on_mouse_entered() -> void:
	hovering = true


func _on_mouse_exited() -> void:
	hovering = false
	
func receive_product(widget : FactoryProductWidget):
	# coming from factory
	# spawn a package, add the widget scene to the package
	match type:
		types.OUTPUT:
			conveyor_belt.receive_product(widget)
		types.INPUT:
			factory_machine.receive_product(widget)
		
	
