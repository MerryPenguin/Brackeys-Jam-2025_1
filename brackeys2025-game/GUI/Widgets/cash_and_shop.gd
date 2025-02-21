extends HBoxContainer

var initial_panel_pos
var panel_open : bool = false

func _ready():
	initial_panel_pos = %ShoppingPanel.position


func _on_button_pressed() -> void:
	if not panel_open:
		show_shopping_panel()
		$Button.text = "Close"
	else:
		hide_shopping_panel()
		$Button.text = "Shop"
	
func show_shopping_panel():
	var tween = create_tween()
	tween.tween_property(%ShoppingPanel, "position", initial_panel_pos + Vector2.LEFT*%ShoppingPanel.size.x , 0.2 )
	$SlideNoise.play()
	panel_open = true
	
func hide_shopping_panel():
	var tween = create_tween()
	tween.tween_property(%ShoppingPanel, "position", initial_panel_pos , 0.5 )
	$SlideNoise.play()
	panel_open = false
	
func _on_globals_cash_changed():
	for button in %ButtonContainer:
		button.disable_if_insufficient_funds()
