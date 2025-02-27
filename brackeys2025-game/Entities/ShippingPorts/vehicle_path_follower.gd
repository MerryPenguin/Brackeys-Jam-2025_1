class_name VehiclePathFollower extends PathFollow2D

## NOTE: IncomingVehiclesPath will try and set this
var speed = 40.0

@export var region : Globals.regions = Globals.regions.AMERICAS

enum states { INCOMING, LOADING, OUTBOUND, DONE }
var state : states = states.INCOMING

signal arrived(region)

func _process(delta):
	match state:
		states.INCOMING:
			move(1, delta)
		states.LOADING:
			pass
		states.OUTBOUND:
			move(-1, delta)
			
			
func move(direction, delta):
	self.progress += direction * speed * delta
	if self.progress_ratio >= 0.95 and state == states.INCOMING:
		arrive()
	elif self.progress_ratio <= 0.05 and state == states.OUTBOUND:
		state == states.DONE
		queue_free()

func arrive():
	state = states.LOADING
	var new_customer = generate_random_customer(region)
	
	var nearest_port = get_nearest_port()
	var new_manifest = generate_random_manifest(nearest_port)
	
	Globals.current_hud.spawn_discriminator(new_manifest)
	$LoadingWaitTimer.start()

func get_nearest_port():
	var ports = get_tree().get_nodes_in_group("ports")
	var nearest_port = Utils.find_closest_node(ports, global_position)


func generate_random_manifest(port) -> ProcurementManifest:
	# figure out what the port has and buy some
	# Do we want to show things we might want, but they don't have?
	var new_manifest : ProcurementManifest = ProcurementManifest.new()
	new_manifest.create_random_requirements_list()
	new_manifest.purchasing_company = null # TODO: come up with some corporations
	new_manifest.purchasing_agent = generate_random_customer_ID(region)
	return new_manifest
	

func generate_random_customer(region):
	var customer_scene = preload("res://Entities/Customers/customer.tscn")
	var new_customer = customer_scene.instantiate()
	new_customer.state = new_customer.states.DETAINED
	return new_customer

func generate_random_customer_ID(region):
	var new_customer_ID = CustomerIdentity.new() # automatically randomizes the stats
	return new_customer_ID

func _on_loading_wait_timer_timeout() -> void:
	state = states.OUTBOUND
	$Sprite2D.scale.x *= -1
