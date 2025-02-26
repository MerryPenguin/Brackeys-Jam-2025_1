extends PathFollow2D

@export var speed = 40.0

enum states { INCOMING, LOADING, OUTBOUND, DONE }
var state : states = states.INCOMING

func _process(delta):
	match state:
		states.INCOMING:
			fly(1, delta)
		states.LOADING:
			pass
		states.OUTBOUND:
			fly(-1, delta)
			
			
func fly(direction, delta):
	self.progress += direction * speed * delta
	if self.progress_ratio >= 0.95 and state == states.INCOMING:
		state == states.LOADING
		$LoadingWaitTimer.start()
	elif self.progress_ratio <= 0.05 and state == states.OUTBOUND:
		state == states.DONE
		queue_free()



func _on_loading_wait_timer_timeout() -> void:
	state = states.OUTBOUND
	$Sprite2D.scale.x *= -1
