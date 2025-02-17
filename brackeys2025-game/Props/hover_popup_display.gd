extends Area2D

var hovering: bool = false
@export_multiline var text : String :
	set(v):
		text = v
		update_label(v)
	get:
		return text


func _ready():
	$Panel/Label.text = text
	$Panel.hide()

func update_label(new_text):
	$Panel/Label.text = new_text

func _on_mouse_entered() -> void:
	hovering = true
	$Timer.set_wait_time(0.2)
	$Timer.start()
	


func _on_mouse_exited() -> void:
	hovering = false
	$Timer.set_wait_time(0.5)
	$Timer.start()


func _on_timer_timeout() -> void:
	match hovering:
		true:
			$Panel.show()
		false:
			$Panel.hide()
