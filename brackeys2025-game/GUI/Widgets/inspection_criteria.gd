## At intervals, generate random inspection criteria

extends HBoxContainer

var current_criteria: Array[String]
@export var duration_between_change : float = 12 # seconds

func _ready():
	update_criteria()
	reset_timer()

func update_criteria():
	current_criteria.clear()
	for child in $List.get_children():
		child.queue_free()
	
	for i in range(randi()%3 + 1):
		add_criterion()
	
	for criterion in current_criteria:
		spawn_label(criterion)
		
	
	
func reset_timer():
	$Timer.set_wait_time(jitter(duration_between_change))

func jitter(num : float):
	return randf_range(num * 0.8, num * 1.25) 
		
func add_criterion():
	var possible_criteria = [
		"glasses",
		"beard",
		"white pants",
		"parrot",
	]
	
	var choice = possible_criteria.pick_random()
	if not current_criteria.has(choice):
		current_criteria.push_back(possible_criteria.pick_random())

func spawn_label(text):
	var new_label = Label.new()
	new_label.text = text
	$List.add_child(new_label)
	if new_label.get_index() < current_criteria.size():
		new_label.text += ", "
	


func _on_timer_timeout() -> void:
	update_criteria()
	reset_timer()
