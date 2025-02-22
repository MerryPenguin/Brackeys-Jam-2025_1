class_name LevelWonMenu
extends OverlaidMenu

signal continue_pressed
signal restart_pressed
signal main_menu_pressed

@export var text : String = "Level Won":
	set(v):
		text = v
		%DescriptionLabel.text = v
	get:
		return text

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if $ConfirmMainMenu.visible:
			$ConfirmMainMenu.hide()
		get_viewport().set_input_as_handled()

func _on_main_menu_button_pressed():
	$ConfirmMainMenu.popup_centered()

func _on_confirm_main_menu_confirmed():
	main_menu_pressed.emit()
	close()

func _on_restart_button_pressed():
	print("Level Won Menu: restart_pressed conntions: ", restart_pressed.get_connections())
	restart_pressed.emit()
	close()

func _on_close_button_pressed():
	continue_pressed.emit()
	close()
