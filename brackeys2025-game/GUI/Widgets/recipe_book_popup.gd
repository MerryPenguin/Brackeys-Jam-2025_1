## Feb 18 Was planning to build a recipe book procedurally,
## but then decided it was easier to build it by hand in Godot inspector.

extends PopupPanel

signal tool_freed(tool)

# walk through the recipes list and make a display
func _ready():
	#create_recipe_book()
	if Globals.current_hud != null:
		tool_freed.connect(Globals.current_hud._on_tool_freed)
	
func create_recipe_book():
	pass
	
	#for recipe_name in Globals.product_recipes:
		#var recipe = Globals.product_recipes[recipe_name]
		
		# if recipe has no requirements, check the type.
		# show the harvester colour which generates it
		# H -> R
		
		# if recipe has requirements, show them, followed by the recipe.
		# X + Y -> A -> Z
		
		# three requirements might need the super aggregator


func _on_button_pressed() -> void:
	self.hide()


func _on_popup_hide() -> void:
	tool_freed.emit(self)
	call_deferred("queue_free")
