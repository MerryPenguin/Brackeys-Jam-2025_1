extends FactoryFloor

signal level_won
var level_won_text = "Congratulations on graduating this extensive employee training course. \n\nYou will now be assigned to a multi-billion dollar logistics center."


	

func _on_skip_button_pressed() -> void:
	show_level_won_overlay(level_won_text)


func _on_aggregator_combiner_input_node_connected() -> void:
	show_level_won_overlay(level_won_text)


func _on_organics_harvester_input_node_connected() -> void:
	show_level_won_overlay(level_won_text)
