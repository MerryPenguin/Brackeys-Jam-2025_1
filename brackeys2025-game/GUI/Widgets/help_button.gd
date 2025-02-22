extends Button

@export_multiline var help_text : String = ""


func _ready():
	%HelpTextLabel.text = help_text
	$InstructionPopupPanel.hide()
	

func _on_pressed() -> void:
	var min_size := Vector2i(384, 384)
	var _desired_window_size := Vector2(512,384)
	$InstructionPopupPanel.popup_centered_clamped(min_size, 0.75)
