extends Node2D



func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	queue_redraw() # might not need this
	

func _draw() -> void:
	draw_circle(Vector2.ZERO, 32, Color.RED, false, 2.0, false)
