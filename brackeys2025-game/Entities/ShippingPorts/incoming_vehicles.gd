extends Node2D

@export var vehicle_scene = preload("res://Entities/ShippingPorts/airplane_path_follower.tscn")
	


func spawn_vehicle():
	var new_vehicle = vehicle_scene.instantiate()
	$Trajectory.add_child(new_vehicle)


func _on_vehicle_spawn_timer_timeout() -> void:
	spawn_vehicle()
