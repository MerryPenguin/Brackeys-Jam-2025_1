extends AudioStreamPlayer2D

func spawn():
	var new_noise : AudioStreamPlayer2D = self.duplicate()
	new_noise.finished.connect(new_noise.queue_free)
	get_tree().get_root().add_child(new_noise)
	new_noise.global_position = global_position
	new_noise.play()
