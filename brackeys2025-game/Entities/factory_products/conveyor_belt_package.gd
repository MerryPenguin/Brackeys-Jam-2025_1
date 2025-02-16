## Conveyor Belt Package moves widgets along conveyor belts

class_name ConveyorBeltPackage extends PathFollow2D

@export var speed : float = 20.0

func _process(delta):
	progress += speed * delta # in pixels
	progress_ratio = min(progress_ratio, 1.0)
