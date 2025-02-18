extends "res://Levels/factory_floor.gd"


func _on_skip_button_pressed() -> void:
	var level_won_overlay = preload("res://GUI/maaack_template/scenes/overlaid_menus/level_won_menu.tscn").instantiate()	
	add_sibling(level_won_overlay)
	level_won_overlay.continue_pressed.connect(_on_next_level_requested)

func _on_next_level_requested():
	# TODO: This needs to emit something to a level manager from Maaack's template.
	# so the system knows which levels are complete.
	GameState.set_current_level(1)
	SceneLoader.load_scene("res://Levels/factory_floor.tscn")
