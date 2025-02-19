## Customer. Temporary feature - walks to the storage bin and buys stuff, then walks away.

class_name RovingCustomer extends CharacterBody2D

var target_destination : Node2D
@export var speed = 30.0

@export_range(0.0, 1.0) var sketchiness_factor : float = 0.25
var dangerous_limit : float = 0.5

@export var widgets_desired : Array[RequirementsManifest]

enum states { MOVING_TO_INSPECTOR, DETAINED, MOVING_TO_SHOP, BROWSING, BUYING, LEAVING }
var state = states.MOVING_TO_SHOP

func _ready():
	$RedLight.hide()
	set_initial_sketchiness()
	check_for_sketchiness()
	create_requirements_manifests()
	

func create_requirements_manifests():
	var req_text = ""
	for i in range((randi()%3) +1):
		var new_manifest = RequirementsManifest.new()
		
		new_manifest.recipe = Globals.product_recipes[Globals.products.values().pick_random()]
		new_manifest.quantity_required = randi()%3+1
		
		new_manifest.generate_random_requirement()
		widgets_desired.push_back(new_manifest)
		req_text += new_manifest.recipe.product_name + ", "
	$HoverPopupDisplay.text = "Customer Wants:\n" + req_text

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
	
func _process(delta):
	update_target()
	move_toward_target(delta)
	attempt_to_buy_product()

func update_target():
	if target_destination == null:
		target_destination = find_nearest_storage_bin()

func find_nearest_storage_bin():
	var bins = get_tree().get_nodes_in_group("storage")
	if bins != null and not bins.is_empty():
		bins.sort_custom(sort_proximity)
		return bins[0]
	
func move_toward_target(_delta):
	# TODO: update this to use navmesh, NavigationAgent2D
	# alternatively, could have them chase a virtual rabbit on a path, like greyhounds on a track
	if target_destination:
		velocity = global_position.direction_to(target_destination.global_position) * speed
		move_and_slide()
		
func attempt_to_buy_product():
	if not $CooldownTimer.is_stopped():
		return
	if target_destination is StorageChest and is_near_storage_bin():
		for manifest in widgets_desired:
			if not manifest.requirements_met():
				var new_item = target_destination.sell(manifest.recipe.product_name, self)
				if new_item != null:
					receive_product(new_item)
					add_child(new_item)
				$CooldownTimer.start()
				if manifest.requirements_met():
					leave()

func leave():
	pass

func _on_selected_for_inspection(inspection_area):
	#go_to_inspector(inspection_area)
	pass

func is_near_storage_bin():
	if target_destination is StorageChest:
		var threshold_sq = 32 * 32 # pixels
		if global_position.distance_squared_to(target_destination.global_position) < threshold_sq:
			return true
	return false


func _on_hover_detection_area_mouse_entered() -> void:
	pass # Replace with function body.


func _on_hover_detection_area_mouse_exited() -> void:
	pass # Replace with function body.

func receive_product(widget : FactoryProductWidget):
	for manifest : RequirementsManifest in widgets_desired:
		if not widget or not widget.recipe:
			push_warning(widget.name, " has no recipe?")
		if manifest.get_widget_name() == widget.recipe.product_name:
			if not manifest.is_full():
				manifest.add(1)

func _on_cooldown_timer_timeout() -> void:
	pass # Replace with function body.
