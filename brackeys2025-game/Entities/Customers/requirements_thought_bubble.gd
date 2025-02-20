extends Control

func update_icons(manifests : Array[RequirementsManifest]):
	for previous_icon in $GridContainer.get_children():
		previous_icon.queue_free()
	for manifest in manifests:
		if manifest.get("recipe"):
			$GridContainer.add_child(make_icon(manifest.recipe))

func make_icon(recipe) -> TextureRect:
	var new_texture_rect = TextureRect.new()
	new_texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	new_texture_rect.custom_minimum_size = Vector2(32,32)
	new_texture_rect.texture = recipe.icon
	return new_texture_rect
	
