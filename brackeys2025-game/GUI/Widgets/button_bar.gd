## When player clicks a factory button,
## the cursor changes into a factory blueprint.
## They can then place the factory on the floor,
## or press escape to cancel.

extends Container

@onready var containers = [ %HarvestersContainer, %CombinatorContainer ]

func _ready():
	setup_button_shortcut_keys()
	%RecipeBookPopup.hide()
	hide_locked_buildings()
	

	
	
func setup_button_shortcut_keys():
	var button_num = 0
	for container in containers:
		for item in container.get_children():
			if item is Button:
				setup_button(item, button_num)
				button_num += 1

func hide_locked_buildings():
	for container in containers:
		for button in container.get_children():
			if button is Button:
				var building_type = button.factory
				if not Globals.unlocked_buildings.has(building_type):
					button.disabled = true
					button.hide()
			
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
	get_tree().get_root().add_child(new_blueprint)
	


func _on_recipes_button_pressed() -> void:
	%RecipeBookPopup.popup_centered_ratio(0.8)
	
func _on_factory_unlocked(factory : Globals.buildings):
	for container in containers:
		for button in container.get_children():
			if button.get("factory") and button.factory == factory:
				button.show()
				button.disabled = false
