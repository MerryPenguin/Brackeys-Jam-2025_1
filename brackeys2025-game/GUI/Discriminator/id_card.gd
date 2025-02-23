extends Node2D

enum states { ON_DESK, TRANSITION, IN_HAND }
var state = states.ON_DESK

var sex = "":
	set(v):
		sex = v
		%Sex.text = v
	get:
		return sex

var education = "":
	set(v):
		%Education.text = v
		education = v
	get:
		return education
	

func _on_id_extents_gui_input(event: InputEvent) -> void:
	if event.is_action("interact") and Input.is_action_just_pressed("interact"):
		if state == states.ON_DESK:
			$AnimationPlayer.play("zoom_id")
			state = states.TRANSITION
		elif state == states.IN_HAND:
			$AnimationPlayer.play("return_id_to_desk")
			state = states.TRANSITION

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state != states.TRANSITION:
		return
	match anim_name:
		"zoom_id":
			state = states.IN_HAND
		"return_id_to_desk":
			state = states.ON_DESK
			
