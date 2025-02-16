extends "res://addons/maaacks_game_template/base/scenes/opening/opening.gd"

func _ready():
	super()
	$BrainstormingPanel.queue_free()
	if OS.is_debug_build():
		#list_all_classes()
		pass

func list_all_classes():
	print("Registered Classes")
	var classes = ProjectSettings.get_global_class_list()
	for item in classes:
		print(item.class)
		
