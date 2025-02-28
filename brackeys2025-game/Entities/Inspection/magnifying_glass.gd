extends Node2D

var has_target : bool

func _process(_delta):
	global_position = get_global_mouse_position()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		$ScanNoise.play()
		var potential_customers : Array = $Area2D.get_overlapping_bodies()
		var potential_vehicles : Array = $Area2D.get_overlapping_areas()
		if potential_customers.size() > 0:
			var customers = potential_customers.filter(is_customer)
			if customers.size() > 0:
				var nearest_customer = Utils.find_closest_node(customers, global_position)
				Globals.current_hud.spawn_discriminator(nearest_customer.manifest)
				call_deferred("queue_free") # Remove the magnifying glass
		elif potential_vehicles.size() > 0:
			var vehicle_areas = potential_vehicles.filter(is_vehicle)
			if vehicle_areas.size() > 0:
				var nearest_vehicle_area = Utils.find_closest_node(vehicle_areas, global_position)
				var nearest_vehicle = nearest_vehicle_area.owner
				if nearest_vehicle.state == nearest_vehicle.states.DETAINED:
					Globals.current_hud.spawn_discriminator(nearest_vehicle.manifest)
					call_deferred("queue_free")
			


func is_customer(body):
	return body.is_in_group("Customers")

func is_vehicle(area):
	return area.owner.is_in_group("Vehicles")
	
