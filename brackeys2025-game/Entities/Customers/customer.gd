## Customer. Temporary feature - walks to the storage bin and buys stuff, then walks away.

class_name RovingCustomer extends CharacterBody2D

var target_destination : Node2D
@export var speed = 30.0

@export_range(0.0, 1.0) var sketchiness_factor : float = 0.25
var dangerous_limit : float = 0.5

#@export var widgets_desired : Array[Globals.products]
#var items_purchased : Array[Globals.products]
#var items_stolen : Array[Globals.products]
var manifest : ProcurementManifest

enum states { MOVING_TO_INSPECTOR, DETAINED, MOVING_TO_SHOP, BROWSING, BUYING, INTENDING_HARM, CAUSING_DAMAGE, LEAVING }
var state : states = states.MOVING_TO_SHOP

@export var max_cycles_to_wait : int = 10
var cycles_waited : int = 0

@onready var identity : CustomerIdentity = %Identity


@onready var storage : StorageComponent = $StorageComponent




signal desires_changed(new_desires)
signal thefts_changed(items_stolen)
signal purchases_changed(items_purchased)


func _ready():
	manifest = ProcurementManifest.new()
	%CyclesRemaining.text = str(max_cycles_to_wait)
	$RedLight.hide()
	set_initial_sketchiness()
	check_for_sketchiness()
	create_requirements_list()
	desires_changed.connect($RequirementsThoughtBubble._on_items_changed)
	thefts_changed.connect($TheftsThoughtBubble._on_items_changed)
	purchases_changed.connect($PurchasesThoughtBubble._on_items_changed)
	$CustomerAvoidanceArea.show()
	
func create_requirements_list():
	manifest.create_random_requirements_list()
	
	var req_text = ""
	for widget in manifest.widgets_desired:
		req_text += Globals.product_recipes[widget].product_name + ", "
	$HoverPopupDisplay.text = "Customer Wants:\n" + req_text
	$RequirementsThoughtBubble.update_icons(manifest.widgets_desired)


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
	state = states.MOVING_TO_INSPECTOR
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
		states.MOVING_TO_INSPECTOR:
			if is_near_inspector(target_destination):
				state = states.DETAINED
				$CheckoutWaitTime.start()
		states.INTENDING_HARM:
			# Move toward a random factory, then cause damage
			if is_near_damage_target(target_destination):
				state = states.CAUSING_DAMAGE
				$AnimationPlayer.play("cause_harm")
		states.CAUSING_DAMAGE:
			#Bounce around for some cooldown period then destroy factory?
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
	for desired_product in manifest.widgets_desired:
		var requirement : ProductWidgetRecipe = Globals.product_recipes[desired_product]
		if target_destination is Marker2D or target_destination.is_in_group("inspection_areas"):
			return
		if target_destination.storage.has_product_named(requirement.product_name):
			if target_destination.has_method("sell"):
				target_destination.sell(requirement.product_name, self) # -> comes back in receive_product
				cycles_waited = 0 # reset timer if they bought something?
		else:
			requirements_met = false
		
		if cycles_waited > max_cycles_to_wait:
			if manifest.items_purchased.size() > 0: # happy customer
				go_to_inspector()
			else: # couldn't find anything.
				if randf() < 0.25:
					become_evil()
				else:
					leave() # Might be stealing?
				
		%CyclesRemaining.text = str(max_cycles_to_wait - cycles_waited)
		$CooldownTimer.start()
	cycles_waited += 1
	if requirements_met and not state == states.INTENDING_HARM:
		go_to_inspector()
	

func leave():
	state = states.LEAVING
	var exit = get_tree().get_first_node_in_group("exits")
	if exit != null:
		target_destination = exit

func become_evil():
	# pick a random factory machine (harvester or aggregator), go there, and bulldoze it.
	var interesting_groups = [ "aggregators", "harvesters" ]
	var machines_of_interest = []
	for group in interesting_groups:
		var group_machines = get_tree().get_nodes_in_group(group)
		if group_machines != null and not group_machines.is_empty():
			machines_of_interest.append_array(group_machines)
	if machines_of_interest != null and not machines_of_interest.is_empty():
		var random_target = machines_of_interest.pick_random()
		state = states.INTENDING_HARM
		target_destination = random_target
		$Unhappy.play()
		$Sprite2D.texture = preload("res://Assets/Images/placeholder/evil_face.png")
	else:
		leave() # nothing to do
	
func _on_selected_for_inspection(_inspection_area):
	#go_to_inspector(inspection_area)
	pass

func is_near_storage_bin(bin : StorageChest):
	if bin:
		var threshold_sq = 64 * 64 # pixels
		if global_position.distance_squared_to(bin.global_position) < threshold_sq:
			return true
	return false

func is_near_damage_target(machine : FactoryMachine):
	if machine:
		var threshold_sq = 96*96
		if global_position.distance_squared_to(machine.global_position) < threshold_sq:
			return true
	return false

func is_near_inspector(inspector):
	if inspector:
		var threshold_sq = 96*96
		if global_position.distance_squared_to(inspector.global_position) < threshold_sq:
			return true
	return false
	

func _on_hover_detection_area_mouse_entered() -> void:
	pass # Replace with function body.


func _on_hover_detection_area_mouse_exited() -> void:
	pass # Replace with function body.

func receive_product(product_idx : Globals.products):
	if not storage.is_full():
		storage.receive_product(product_idx)
		remove_product_from_desires_list(product_idx)
		add_product_to_carrying_lists(product_idx)

func add_product_to_carrying_lists(product_idx : Globals.products):
	if randf() < 0.8: # paid for it, no problem
		Globals.cash += Utils.lookup_value(product_idx)
		manifest.items_purchased.push_back(product_idx)
		purchases_changed.emit(manifest.items_stolen)
		$BoughtSomething.play()
		
	else: # stole the product
		manifest.items_stolen.push_back(product_idx)
		thefts_changed.emit(manifest.items_stolen)
		



func remove_product_from_desires_list(product_idx : Globals.products):
	manifest.widgets_desired.erase(product_idx)
	desires_changed.emit(manifest.widgets_desired)
	if manifest.widgets_desired.size() == 0:
		leave()

func _on_cooldown_timer_timeout() -> void:
	pass # not required. we just check is_stopped() directly for cooldowns


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if state == states.LEAVING:
		queue_free()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "cause_harm":
		destroy_building()

func destroy_building():
	if state == states.CAUSING_DAMAGE and target_destination != null and is_instance_valid(target_destination):
		if target_destination.is_in_group("harvesters") or target_destination.is_in_group("aggregators"):
			target_destination.destruct() # should play a noise.
			queue_free()


func _on_checkout_wait_time_timeout() -> void:
	if state == states.DETAINED:
		if randf() < 0.5:
			become_evil()
		else:
			leave()

func _on_discriminator_approved():
	# TODO: Add some juice and payoff (if we still want floating head customers)
	queue_free()
	
func _on_discriminator_denied():
	# TODO: Add some juice and payoff (if we still want floating head customers)
	queue_free()
