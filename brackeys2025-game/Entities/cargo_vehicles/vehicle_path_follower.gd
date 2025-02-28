## VehiclePathFollower.tscn is meant to be used as an inherited scene by cargo vehicles
## Each new scene needs sprites inside the Sprite2D node, and a CollisionShape2D inside the Area2D node.

class_name VehiclePathFollower extends PathFollow2D

## NOTE: IncomingVehiclesPath will try and set this
var speed = 40.0

@export var max_capacity : int = 10

enum states { INCOMING, LOADING, DETAINED, OUTBOUND, DONE }
var state : states = states.INCOMING

signal arrived(region)
var port : StorageChest
var region : Globals.regions = Globals.regions.AMERICAS

var manifest : ProcurementManifest
var products_in_cargo : Array[Globals.products] # just store the product index (enum), not the node
var cycles_waited : int = 0
var max_wait_cycles : int = 10

func _ready():
	manifest = generate_random_manifest(region)
	validate_dependencies()

func validate_dependencies():
	if $Sprites.get_child_count() == 0:
		push_warning(self.name , " needs Sprites inside the Sprites node")
	if $Area2D.get_child_count() == 0:
		push_warning(self.name , " needs collision shapes inside the Area2D node")
	$ReadyForInspection.hide()
	

func activate(new_port : StorageChest, new_region : Globals.regions):
	port = new_port
	region = new_region

func _process(delta):
	match state:
		states.INCOMING:
			move(1, delta)
		states.LOADING:
			load_cargo(delta)
		states.OUTBOUND:
			move(-1, delta)
			
func receive_product(product_idx: Globals.products):
	products_in_cargo.push_back(product_idx)
	popup_icon(product_idx)
	# payment should come on approval of paperwork
	

func popup_icon(product_idx : Globals.products):
	print(self.name, " received ", Globals.product_recipes[product_idx].product_name)
	var new_icon = Sprite2D.new()
	new_icon.texture = Globals.product_recipes[product_idx].icon
	new_icon.scale = Vector2(4,4)
	new_icon.global_rotation = 0
	add_child(new_icon)
	new_icon.global_position = global_position + Vector2(0, -16)
	
	var tween = new_icon.create_tween()
	tween.tween_property(new_icon, "global_position", new_icon.global_position + Vector2(0, -32), 0.33)
	tween.tween_property(new_icon, "scale", new_icon.scale * 2.0, 0.33)
	tween.tween_callback(new_icon.queue_free)

func load_cargo(delta):
	if $LoadingWaitTimer.is_stopped():
		# check the list of goods in the nearest store, if they have any on your manifest, add one
		# then restart the timer and do it again.
		var found_desired_product = false
		for product_idx : Globals.products in manifest.widgets_desired:
			if port.storage.has_product_num(product_idx):
				port.sell(Globals.product_recipes[product_idx].product_name, self)
				found_desired_product = true
		if not found_desired_product: #take whatever they've got at a discount
			port.sell_oldest_product(self)
		cycles_waited += 1
		$LoadingWaitTimer.start()
		if products_in_cargo.size() >= max_capacity or cycles_waited > max_wait_cycles:
			queue_for_inspection()

func queue_for_inspection():
	state = states.DETAINED
	# wave a sprite indicating ready for inspection. Then when player uses magnifying glass, pop up a discriminator
	$InspectionWaitTimer.start()
	$ReadyForInspection.show()
	
func leave():
	state = states.OUTBOUND
	$Sprites.scale.x *= -1
	$ReadyForInspection.hide()

func move(direction, delta):
	self.progress += direction * speed * delta
	if self.progress_ratio >= 0.95 and state == states.INCOMING:
		arrive()
	elif self.progress_ratio <= 0.05 and state == states.OUTBOUND:
		state = states.DONE
		queue_free()

func arrive():
	state = states.LOADING
	var new_customer = generate_random_customer(region)
	var new_manifest = generate_random_manifest(region)
	
	#Globals.current_hud.spawn_discriminator(new_manifest) # Leave this to the magnifying glass
	$LoadingWaitTimer.start()

func get_nearest_port():
	var ports = get_tree().get_nodes_in_group("ports")
	var nearest_port = Utils.find_closest_node(ports, global_position)


func generate_random_manifest(manifest_region) -> ProcurementManifest:
	# figure out what the port has and buy some
	# Do we want to show things we might want, but they don't have?
	var new_manifest : ProcurementManifest = ProcurementManifest.new()
	new_manifest.create_random_requirements_list()
	new_manifest.purchasing_company = null # TODO: come up with some corporations
	new_manifest.purchasing_agent = generate_random_customer_ID(manifest_region)
	return new_manifest
	

func generate_random_customer(new_region):
	var customer_scene = preload("res://Entities/Customers/customer.tscn")
	var new_customer = customer_scene.instantiate()
	new_customer.state = new_customer.states.DETAINED
	return new_customer

func generate_random_customer_ID(region):
	var new_customer_ID = CustomerIdentity.new() # automatically randomizes the stats
	return new_customer_ID

func _on_loading_wait_timer_timeout() -> void:
	pass
	#state = states.OUTBOUND
	#$Sprite2D.scale.x *= -1


func _on_inspection_wait_timer_timeout() -> void:
	if state == states.DETAINED:
		# player didn't click on you in time
		leave()
