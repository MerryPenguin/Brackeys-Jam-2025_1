## Factory Machine
# take inputs, add time, make outputs

extends Node2D

@export var required_inputs : Array = []
@export var production_time : float = 10.0 # time to convert requirements into output
@export var output_widget : PackedScene

@onready var connectors : Node2D = $Connectors

func _ready():
	connectors.hide()


func _on_mouse_detection_area_mouse_entered() -> void:
	connectors.show()

func _on_mouse_detection_area_mouse_exited() -> void:
	connectors.hide()
