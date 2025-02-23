extends Node2D

enum states { ON_DESK, TRANSITION, IN_HAND }
var state = states.ON_DESK

var affiliations = "":
	set(v):
		affiliations = v
		%Affiliations.text = v
	get:
		return affiliations

var id = "":
	set(v):
		%ID.text = v
		id = v
	get:
		return id
	




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if state != states.TRANSITION:
		#return
	match anim_name:
		"zoom_id":
			state = states.IN_HAND
		"return":
			state = states.ON_DESK
			




func _on_passport_extents_gui_input(event: InputEvent) -> void:
	if event.is_action("interact") and Input.is_action_just_pressed("interact"):
		print("got the click")
		match state:
			states.ON_DESK:
				print("zooming")
				$AnimationPlayer.play("zoom_id")
				state = states.TRANSITION
			states.IN_HAND:
				print("trying to return. problem might be animatino player")
				$AnimationPlayer.play("return")
				state = states.TRANSITION
