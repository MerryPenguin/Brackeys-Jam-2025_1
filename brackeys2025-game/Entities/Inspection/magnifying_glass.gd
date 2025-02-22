extends Node2D

var has_target : bool

func _process(_delta):
	global_position = get_global_mouse_position()
	
	#if Input.is_action_just_pressed("interact"):
		#var potential_customers : Array = $Area2D.get_overlapping_bodies()
		#if potential_customers.size() > 0:
			#var customers = potential_customers.filter(is_customer)
			#if customers.size() > 0:
				#var nearest_customer = Utils.find_closest_node(customers, global_position)
				#Globals.current_hud.spawn_discriminator(nearest_customer)
			#
				## Should we also queue_free the customer? 

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		$ScanNoise.play()
		var potential_customers : Array = $Area2D.get_overlapping_bodies()
		if potential_customers.size() > 0:
			var customers = potential_customers.filter(is_customer)
			if customers.size() > 0:
				var nearest_customer = Utils.find_closest_node(customers, global_position)
				Globals.current_hud.spawn_discriminator(nearest_customer)
				call_deferred("queue_free") # Remove the magnifying glass


func is_customer(body):
	return body.is_in_group("Customers")
