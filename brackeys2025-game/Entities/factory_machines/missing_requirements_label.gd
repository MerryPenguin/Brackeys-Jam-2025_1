extends Label

var hovered : bool = false

func _ready():
	$DetailsLabel.hide()
	
func _on_info_hover_area_mouse_entered() -> void:
	hovered = true

	$DetailsLabel.text = "Producing: " + owner.current_recipe.product_name	
	if not owner.requirements_met():
		$DetailsLabel.text += "\nMissing: "
		for requirement in owner.get_missing_requirements():
			$DetailsLabel.text += "\n\t" + requirement
	$DetailsLabel.show()

func _on_info_hover_area_mouse_exited() -> void:
	hovered = false
	$DisplayTimer.set_wait_time(2.0)
	$DisplayTimer.start()


func _on_display_timer_timeout() -> void:
	$DetailsLabel.hide()
