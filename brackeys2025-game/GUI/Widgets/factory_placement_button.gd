extends Button

@export var factory_scene : PackedScene
var hovering : bool = false
var timer : Timer

func _ready():
	setup_hover()
	
func setup_hover():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.set_wait_time(0.1)
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	hide_popup_info()

func hide_popup_info():
	for child in get_children():
		if child is Label:
			child.hide()

func show_popup_info():
	for child in get_children():
		if child is Label:
			child.show()

func _on_mouse_entered():
	hovering = true
	timer.set_wait_time(0.1)
	timer.start()

func _on_mouse_exited():
	hovering = false
	timer.set_wait_time(1.0)
	timer.start()
	
func _on_timer_timeout():
	if hovering:
		show_popup_info()
	else:
		hide_popup_info()
