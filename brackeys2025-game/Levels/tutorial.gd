extends FactoryFloor

signal level_won
var level_won_text = "Congratulations on graduating this extensive employee training course. \n\nYou will now be assigned to a multi-billion dollar logistics center."


func win(text):
	show_level_won_overlay(text, "res://Levels/factory_floor.tscn")

func _on_skip_button_pressed() -> void:
	win(level_won_text)


func _on_aggregator_combiner_input_node_connected() -> void:
	win(level_won_text)


func _on_organics_harvester_input_node_connected() -> void:
	win(level_won_text)
