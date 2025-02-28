extends Label


func _process(delta):
	var vehicle = owner
	self.text = vehicle.states.keys()[vehicle.state]
		
