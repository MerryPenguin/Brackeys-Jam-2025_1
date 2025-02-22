extends Control

enum list_types { DESIRES, PURCHASED, STOLEN }
@export var list_type = list_types.DESIRES

func update_icons(products : Array[Globals.products]):
	for previous_icon in $GridContainer.get_children():
		previous_icon.queue_free()
	for product in products:
		$GridContainer.add_child(make_icon(Globals.product_recipes[product]))

func make_icon(recipe) -> TextureRect:
	var new_texture_rect = TextureRect.new()
	new_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	new_texture_rect.custom_minimum_size = Vector2(32,32)
	new_texture_rect.texture = recipe.icon
	return new_texture_rect
	
func _on_items_changed(new_item_list : Array[Globals.products]):
	update_icons(new_item_list)
	
