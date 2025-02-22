## Interaction Button
## Show an icon for the current recipe.
## optional: allow user to change recipes manually

extends Node2D

signal recipe_changed(recipe)

func _ready():
	$Panel.hide()
	populate_grid_container()
	if owner.is_in_group("aggregators"):
		$Button.disabled = true
	

func _on_button_pressed() -> void:
	popup_widget_selection_panel()

func popup_widget_selection_panel():
	
	$Panel.show()

func populate_grid_container():
	var buttons = %Buttons.get_children()
	## NOTE: Workaround for bug in html export.. we need two buttons for each harvester already set up.
	for new_button in buttons:
		new_button.pressed.connect(_on_recipe_button_pressed.bind(new_button.recipe))


func is_recipe(item):
	return item is ProductWidgetRecipe

func is_recipe_unlocked(recipe):
	if owner != null: # children are instantiated before parents.
		return recipe in owner.unlocked_recipes


func dir_contents(path : String):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				#print("Found file: " + file_name)
				files.push_back(path.path_join(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files

func _on_recipe_button_pressed(recipe : ProductWidgetRecipe):
	$Button.icon = recipe.icon
	$Button.text = ""
	$Panel.hide()
	recipe_changed.emit(recipe)

func _on_factory_machine_recipe_changed(recipe : ProductWidgetRecipe):
	$Button.icon = recipe.icon
	$Button.text = ""
	
