extends CanvasLayer

func _init():
	Globals.current_hud = self

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		var active_tools = %ButtonBar.active_tools
		if active_tools.is_empty():
			call_deferred("spawn_pause_menu")
		else:
			print(active_tools)

func spawn_pause_menu():
	var pause_menu = preload("res://GUI/maaack_template/scenes/overlaid_menus/pause_menu.tscn").instantiate()
	add_child(pause_menu)
	
func spawn_discriminator(customer):
	var discriminator = preload("res://GUI/Discriminator/discriminator.tscn").instantiate()
	add_child(discriminator)
	discriminator.activate(customer)
	
	
	
func _on_factory_unlocked(factory):
	%ButtonBar._on_factory_unlocked(factory)

func _on_tool_freed(tool):
	%ButtonBar._on_tool_freed(tool)
