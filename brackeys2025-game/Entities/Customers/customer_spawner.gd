## Customer Spawner -- spawns customers at random intervals

# Some of those customers might have to go through secondary inspection


extends Path2D
@export var time_between_customers : float = 5.0
@export var num_to_spawn : int = 1


func _on_timer_timeout() -> void:
	var jitter_factor = randf_range(0.8, 1.25)
	$Timer.set_wait_time(time_between_customers * jitter_factor)
	spawn_customers(num_to_spawn)
	
func spawn_customers(num):
	for i in range(num):
		var new_customer = preload("res://Entities/Customers/customer.tscn").instantiate()
		$PathFollow2D.progress_ratio = randf()
		Globals.current_level.spawn_customer(new_customer, $PathFollow2D.global_position)
