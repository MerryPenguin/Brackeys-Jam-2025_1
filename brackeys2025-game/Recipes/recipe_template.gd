class_name ProductWidgetRecipe extends Resource
# Note about resources: they're re-used / shared between scenes.
# Therefore, if you edit one, it'll change on all.

@export var required_inputs : Array[RequirementsManifest] = []

@export var production_time : float = 10.0 # time to convert requirements into output
@export var output_widget : PackedScene # NOTE: It might be smarter to use paths instead of packed scenes. we'll see.
@export var icon : Texture2D
