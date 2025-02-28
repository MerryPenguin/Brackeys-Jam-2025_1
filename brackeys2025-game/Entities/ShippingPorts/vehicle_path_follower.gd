class_name VehiclePathFollower extends PathFollow2D

## NOTE: IncomingVehiclesPath will try and set this
var speed = 40.0

@export var max_capacity : int = 10

enum states { INCOMING, LOADING, OUTBOUND, DONE }
var state : states = states.INCOMING

signal arrived(region)
var port : StorageChest
var region : Globals.regions = Globals.regions.AMERICAS

var manifest : ProcurementManifest
var products_in_cargo : Array[Globals.products] # just store the product index (enum), not the node


func _ready():
	manifest = generate_random_manifest(region)

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
			
func receive_product(item: FactoryProductWidget):
	products_in_cargo.push_back(Globals.get_product_by_name(item.recipe.product_name))
	popup_icon(item.recipe.icon)
	item.queue_free()

func popup_icon(icon):
	var new_icon = Sprite2D.new()
	new_icon.texture = icon
	var tween = new_icon.create_tween()
	tween.tween_property(new_icon, "position", Vector2(0, 64), 0.25)
	tween.tween_callback(new_icon.queue_free)

func load_cargo(delta):
	if $LoadingWaitTimer.is_stopped():
		# check the list of goods in the nearest store, if they have any on your manifest, add one
		# then restart the timer and do it again.
		for product_idx : Globals.products in manifest.widgets_desired:
			if port.has_item(product_idx):
				port.sell(Globals.recipes[product_idx].product_name, self)
			
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
	
	Globals.current_hud.spawn_discriminator(new_manifest)
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
