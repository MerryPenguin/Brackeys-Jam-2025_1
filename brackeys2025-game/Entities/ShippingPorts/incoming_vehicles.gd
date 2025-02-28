extends Node2D

@export var vehicle_scene = preload("res://Entities/ShippingPorts/airplane_path_follower.tscn")

## NOTE: Airport, RailPort and ShipPort will try and set these
var interval : float = 3.0 ## default time between vehicles
var region : Globals.regions = Globals.regions.AMERICAS
var port : StorageChest

@export var speed : float = 40.0

func _ready():
	pass

func activate(new_port : StorageChest, new_region : Globals.regions, new_interval : float):
	port = new_port
	region = new_region
	interval = new_interval
	$VehicleSpawnTimer.set_wait_time(interval)
	$VehicleSpawnTimer.start()
	

func spawn_vehicle():
	var new_vehicle = vehicle_scene.instantiate()
	$Trajectory.add_child(new_vehicle)
	new_vehicle.speed = speed
	new_vehicle.activate(port, region, )


func _on_vehicle_spawn_timer_timeout() -> void:
	spawn_vehicle()

func _on_previous_vehicle_freed():
	$VehicleSpawnTimer.start()
	
