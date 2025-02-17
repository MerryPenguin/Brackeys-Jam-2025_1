extends CharacterBody2D

var target_destination : Node2D
@export var speed = 30.0

@export_range(0.0, 1.0) var sketchiness_factor : float = 0.25
var dangerous_limit : float = 0.5

func _ready():
	$RedLight.hide()
	set_initial_sketchiness()
	check_for_sketchiness()

func set_initial_sketchiness():
	sketchiness_factor = randf()

func check_for_sketchiness():
	if sketchiness_factor >= dangerous_limit:
		add_sketchy_props()
		go_to_inspector()

func add_sketchy_props():
	# TODO: show more than 1 and make sure they don't occlude each other
	$SketchyProp.show_random()
	

func go_to_inspector(inspector : Node2D = null):
	if inspector == null:
		var inspectors = get_tree().get_nodes_in_group("inspection_areas")
		inspectors.sort_custom(sort_proximity)
		target_destination = inspectors[0]
	else:
		target_destination = inspector
	$RedLight.show()

func sort_proximity(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	
func _process(delta):
	update_target()
	move_toward_target(delta)

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

func _on_selected_for_inspection(inspection_area):
	go_to_inspector(inspection_area)
