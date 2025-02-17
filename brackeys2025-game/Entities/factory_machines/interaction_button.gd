extends Node2D

signal recipe_changed(recipe)

func _ready():
	$Panel.hide()
	populate_grid_container()

func _on_button_pressed() -> void:
	popup_widget_selection_panel()

func popup_widget_selection_panel():
	
	$Panel.show()

func populate_grid_container():
	var recipes = get_recipes()
	for recipe in recipes:
		var new_button = Button.new()
		
		new_button.icon = recipe.icon
		new_button.expand_icon = true
		new_button.custom_minimum_size = Vector2(32, 32)
		new_button.pressed.connect(_on_recipe_button_pressed.bind(recipe))
		%Buttons.add_child(new_button)
		
func get_recipes():
	var possible_recipes = dir_contents("res://Recipes/")
	var actual_recipies = []
	for possible_recipe_path : String in possible_recipes:
		if possible_recipe_path.get_extension() == "tres":
			var item = load(possible_recipe_path)
			if item is ProductWidgetRecipe:
				actual_recipies.push_back(item)
	return actual_recipies

func is_recipe(item):
	return item is ProductWidgetRecipe


func dir_contents(path : String):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				print("Found file: " + file_name)
				files.push_back(path.path_join(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files

func _on_recipe_button_pressed(recipe):
	$Panel.hide()
	recipe_changed.emit(recipe)
