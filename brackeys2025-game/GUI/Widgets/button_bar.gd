## When player clicks a factory button,
## the cursor changes into a factory blueprint.
## They can then place the factory on the floor,
## or press escape to cancel.

extends GridContainer

func _ready():
	setup_button_shortcut_keys()
	%RecipeBookPopup.hide()
	
func setup_button_shortcut_keys():
	var button_num = 0
	for item in get_children():
		if item is Button:
			setup_button(item, button_num)
			button_num += 1
	
			
func setup_button(button : Button, button_num: int):
	
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.expand_icon = true
	button.pressed.connect(_on_button_pressed.bind(button))
	button.shortcut = Shortcut.new()
	var event_key = InputEventKey.new()
	var keycodes = [ KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7 ]
	event_key.keycode = keycodes[button_num]
	button.shortcut.events.push_back(event_key)
	

func _on_button_pressed(button : Button):
	if "Harvester" in button.name:
		spawn_factory_blueprint(button.factory_scene)
	elif "Combiner" in button.name:
		spawn_factory_blueprint(button.factory_scene)
	elif "Recipes" in button.name:
		print("player wants to open recipe book")

func spawn_factory_blueprint(factory_scene):
	var new_blueprint = preload("res://Entities/factory_blueprints/factory_blueprint.tscn").instantiate()
	new_blueprint.factory_scene = factory_scene
	add_sibling(new_blueprint)
	


func _on_recipes_button_pressed() -> void:
	%RecipeBookPopup.popup_centered_ratio(0.67)
	
