extends Node2D

func _ready():
	$CustomerRef.queue_free()
	for prop in get_children():
		prop.hide()

func show_random():
	get_children().pick_random().show()
	
