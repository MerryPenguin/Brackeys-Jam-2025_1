## When player clicks a factory button,
## the cursor changes into a factory blueprint.
## They can then place the factory on the floor,
## or press escape to cancel.

extends GridContainer

func _ready():
	for item in get_children():
		if item is Button:
			setup_button(item)
			
func setup_button(button : Button):
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.expand_icon = true
	button.pressed.connect(_on_button_pressed.bind(button))


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
	
