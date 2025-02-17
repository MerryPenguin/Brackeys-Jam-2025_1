# Inspector -- go here to inspect customers

extends Node2D
@export var time_between_inspections : float = 8.0 # seconds


func _ready():
	%RedLight.hide()
	%GreenLight.hide()
	$RandomInspectionTimer.start()

func call_customer():
	var customer = pick_random_customer()
	if customer:
		customer._on_selected_for_inspection(self)
	%RedLight.show()

func pick_random_customer():
	var customers = get_tree().get_nodes_in_group("customers")
	if customers != null and customers.size() > 0:
		return customers.pick_random()


func _on_random_inspection_timer_timeout() -> void:
	call_customer()
	$RandomInspectionTimer.set_wait_time(randf_range(time_between_inspections*0.75, time_between_inspections*1.5))
	$RandomInspectionTimer.start()

func _on_inspection_completed():
	%RedLight.hide()
	%GreenLight.show()
	
