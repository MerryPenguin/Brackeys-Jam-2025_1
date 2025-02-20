## Customer. Temporary feature - walks to the storage bin and buys stuff, then walks away.

class_name RovingCustomer extends CharacterBody2D

var target_destination : Node2D
@export var speed = 30.0

@export_range(0.0, 1.0) var sketchiness_factor : float = 0.25
var dangerous_limit : float = 0.5

@export var widgets_desired : Array[RequirementsManifest]

enum states { MOVING_TO_INSPECTOR, DETAINED, MOVING_TO_SHOP, BROWSING, BUYING, LEAVING }
var state = states.MOVING_TO_SHOP

@export var max_cycles_to_wait : int = 10
var cycles_waited : int = 0

@onready var storage : StorageComponent = $StorageComponent

func _ready():
	%CyclesRemaining.text = str(max_cycles_to_wait)
	$RedLight.hide()
	set_initial_sketchiness()
	check_for_sketchiness()
	create_requirements_manifests()
	

func create_requirements_manifests():
	var req_text = ""
	for i in range((randi()%3) +1):
		var new_manifest : RequirementsManifest = RequirementsManifest.new()
		
		var random_choice = Globals.products.values().pick_random()
		var random_recipe : ProductWidgetRecipe = Globals.product_recipes[random_choice]
		#var random_recipe : ProductWidgetRecipe = Globals.product_recipes[Globals.products.ASH]

		new_manifest.recipe = random_recipe
		new_manifest.quantity_required = randi()%3+1
		
		new_manifest.generate_random_requirement()
		widgets_desired.push_back(new_manifest)
		req_text += new_manifest.recipe.product_name + ", "
		
	$HoverPopupDisplay.text = "Customer Wants:\n" + req_text
	$RequirementsThoughtBubble.update_icons(widgets_desired)

func set_initial_sketchiness():
	sketchiness_factor = randf()

func check_for_sketchiness():
	if sketchiness_factor >= dangerous_limit:
		add_sketchy_props()
		#go_to_inspector()

func add_sketchy_props():
	# TODO: show more than 1 and make sure they don't occlude each other
	$SketchyProp.show_random()
	

func go_to_inspector(inspector : Node2D = null):
	if inspector == null:
		var inspectors = get_tree().get_nodes_in_group("inspection_areas")
		if inspectors != null and not inspectors.is_empty():
			inspectors.sort_custom(sort_proximity)
			target_destination = inspectors[0]
	else:
		target_destination = inspector
	#$RedLight.show()

func sort_proximity(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)

func sort_vacancy(a,b):
	return a.get_customer_count() < b.get_customer_count()
	

func _process(delta):
	%StateLabel.text = states.keys()[state]
	update_target()
	move_toward_target(delta)
	
	match state:
		states.MOVING_TO_SHOP:
			if is_near_storage_bin(target_destination):
				state = states.BROWSING
		states.BROWSING:
			attempt_to_buy_product()
		states.LEAVING:
			pass
		

func update_target():
	if target_destination == null:
		match state:
			states.MOVING_TO_SHOP:
				target_destination = find_least_occupied_storage_bin()
			states.BROWSING:
				pass
			states.LEAVING:
				target_destination = get_tree().get_first_node_in_group("exits")



func find_nearest_storage_bin():
	var bins = get_tree().get_nodes_in_group("storage")
	if bins != null and not bins.is_empty():
		bins.sort_custom(sort_proximity)
		return bins[0]

func find_least_occupied_storage_bin():
	var bins = get_tree().get_nodes_in_group("storage")
	if bins != null and not bins.is_empty():
		bins.sort_custom(sort_vacancy)
		return bins[0]


	
func move_toward_target(_delta):
	# TODO: update this to use navmesh, NavigationAgent2D
	# alternatively, could have them chase a virtual rabbit on a path, like greyhounds on a track
	if target_destination:
		var dir_vector = global_position.direction_to(target_destination.global_position)
		dir_vector += get_avoidance_vector()
		if get_avoidance_vector().length_squared() > 0.1:
			dir_vector /= 2.0
		velocity = dir_vector * speed
		
		
		move_and_slide()

func get_avoidance_vector():
	var nearby_customers = []
	var nearby_bodies = $CustomerAvoidanceArea.get_overlapping_bodies()
	for body in nearby_bodies:
		if body is RovingCustomer and body != self:
			nearby_customers.push_back(body)
	var vector = Vector2.ZERO
	for customer in nearby_customers:
		vector += customer.global_position.direction_to(global_position)
	vector /= max(nearby_customers.size(), 1)
	return vector
	
func can_buy():
	var allowed = true
	if not target_destination.has_method("sell"):
		allowed = false
	elif state != states.BROWSING:
		allowed = false
	elif not $CooldownTimer.is_stopped():
		allowed = false
	elif not target_destination is StorageChest:
		allowed = false
	elif not is_near_storage_bin(target_destination):
		allowed = false
	return allowed
		
func attempt_to_buy_product():
	if not can_buy():
		return

	var requirements_met = true
	for manifest in widgets_desired:
		var requirement = manifest.get_requirements()
		if target_destination is Marker2D: # Not sure why i need this after we already verified that the target is a storage chest.. may be an unexpected multithreading issue, timers change variables even during a cycle.
			return
		if target_destination.storage.has_product_named(requirement[0].product_name, requirement[1]):
			if target_destination.has_method("sell"):
				target_destination.sell(manifest.recipe.product_name, self)
				cycles_waited = 0
		else:
			requirements_met = false
		
		if cycles_waited > max_cycles_to_wait:
			leave()
		%CyclesRemaining.text = str(max_cycles_to_wait - cycles_waited)
		$CooldownTimer.start()
		if requirements_met:
			leave()
	cycles_waited += 1

func leave():
	state = states.LEAVING
	var exit = get_tree().get_first_node_in_group("exits")
	if exit != null:
		target_destination = exit

func _on_selected_for_inspection(inspection_area):
	#go_to_inspector(inspection_area)
	pass

func is_near_storage_bin(bin : StorageChest):
	if bin:
		var threshold_sq = 64 * 64 # pixels
		if global_position.distance_squared_to(bin.global_position) < threshold_sq:
			return true
	return false


func _on_hover_detection_area_mouse_entered() -> void:
	pass # Replace with function body.


func _on_hover_detection_area_mouse_exited() -> void:
	pass # Replace with function body.

func receive_product(widget : FactoryProductWidget):
	if not storage.is_full():
		storage.receive_product(widget)

func _on_cooldown_timer_timeout() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if state == states.LEAVING:
		queue_free()
