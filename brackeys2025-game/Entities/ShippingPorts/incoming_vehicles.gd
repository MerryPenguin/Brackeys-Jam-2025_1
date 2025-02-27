extends Node2D

@export var vehicle_scene = preload("res://Entities/ShippingPorts/airplane_path_follower.tscn")
@export var region : Globals.regions = Globals.regions.AMERICAS

## NOTE: Airport, RailPort and ShipPort will try and set this
var interval : float = 3.0 ## default time between vehicles

@export var speed : float = 40.0

func _ready():
	$VehicleSpawnTimer.set_wait_time(interval)
	$VehicleSpawnTimer.start()

func spawn_vehicle():
	var new_vehicle = vehicle_scene.instantiate()
	$Trajectory.add_child(new_vehicle)
	new_vehicle.speed = speed


func _on_vehicle_spawn_timer_timeout() -> void:
	spawn_vehicle()

func _on_previous_vehicle_freed():
	$VehicleSpawnTimer.start()
	
