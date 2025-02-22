extends "res://Levels/factory_floor.gd"

signal level_won

func _on_skip_button_pressed() -> void:
	var level_won_overlay = preload("res://GUI/maaack_template/scenes/overlaid_menus/level_won_menu.tscn").instantiate()	
	level_won_overlay.text = """Congratulations on graduating this extensive employee training course. \n\nYou will now be assigned to a multi-billion dollar logistics center."""
	add_sibling(level_won_overlay)
	level_won_overlay.continue_pressed.connect(_on_next_level_requested)

func _on_next_level_requested():
	# TODO: This needs to emit something to a level manager from Maaack's template.
	# so the system knows which levels are complete.
	GameState.set_current_level(1)
	SceneLoader.load_scene("res://Levels/factory_floor.tscn")


func _on_aggregator_combiner_input_node_connected() -> void:
	_on_skip_button_pressed()


func _on_organics_harvester_input_node_connected() -> void:
	_on_skip_button_pressed()
