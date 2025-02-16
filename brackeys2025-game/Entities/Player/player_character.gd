extends CharacterBody2D

func _init():
	Globals.current_player = self

func _ready():
	pass
	
func _physics_process(delta: float) -> void:
	move(delta)
	
func move(_delta):
	var speed = 200.0
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	move_and_slide()
