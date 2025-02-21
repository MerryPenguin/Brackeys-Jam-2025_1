extends Label

var hovered : bool = false

func _ready():
	$DetailsLabel.hide()
	
func _on_info_hover_area_mouse_entered() -> void:
	hovered = true
	update_details_label()

func update_details_label():
	$DetailsLabel.text = ""
	if owner.current_recipe != null and owner.requirements_met(owner.current_recipe):
		$DetailsLabel.text += "Producing: " + owner.current_recipe.product_name
	$DetailsLabel.show()

func _on_info_hover_area_mouse_exited() -> void:
	hovered = false
	$DisplayTimer.set_wait_time(2.0)
	$DisplayTimer.start()


func _on_display_timer_timeout() -> void:
	$DetailsLabel.hide()
