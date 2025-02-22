extends Node2D

signal tool_freed(tool)

func _ready():
	tool_freed.connect(Globals.current_hud._on_tool_freed)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	queue_redraw() # might not need this
	if Input.is_action_just_pressed("interact"):
		destroy_buildings_under_cursor()

	if Input.is_action_just_pressed("ui_cancel"):
		tool_freed.emit(self)
		queue_free()

func destroy_buildings_under_cursor():
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.owner == null:
			continue
		if body.owner.is_in_group("harvesters") or body.owner.is_in_group("aggregators"):
			body.owner.destruct()
	

func _draw() -> void:
	draw_circle(Vector2.ZERO, 32, Color.RED, false, 2.0, false)
