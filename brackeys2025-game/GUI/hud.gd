extends CanvasLayer

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		spawn_pause_menu()

func spawn_pause_menu():
	var pause_menu = preload("res://GUI/maaack_template/scenes/overlaid_menus/pause_menu.tscn").instantiate()
	add_child(pause_menu)
	
