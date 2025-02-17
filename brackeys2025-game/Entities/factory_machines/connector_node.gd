extends Area2D

enum types { INPUT, OUTPUT }
@export var type : types = types.INPUT

enum states { IDLE, DRAWING }
var state : states = states.IDLE

var connected : bool = false
var hovering : bool = false


func _ready():
	$Label.text = types.keys()[type].capitalize()


func _process(_delta):
	if state == states.IDLE and hovering == true:
		if Input.is_action_just_pressed("interact"):
			begin_drawing()
	elif state == states.DRAWING and Input.is_action_just_released("interact"):
		stop_drawing()


func begin_drawing():
	state = states.DRAWING
	var new_conveyor = preload("res://Entities/Connectors/conveyor_belt.tscn").instantiate()
	new_conveyor.state = new_conveyor.states.DRAWING
	Globals.current_level.spawn_conveyor_belt(new_conveyor)
	new_conveyor.global_position = Vector2.ZERO

func stop_drawing():
	# conveyor belts handle their own drawing
	state = states.IDLE

func _on_mouse_entered() -> void:
	hovering = true


func _on_mouse_exited() -> void:
	hovering = false
	
