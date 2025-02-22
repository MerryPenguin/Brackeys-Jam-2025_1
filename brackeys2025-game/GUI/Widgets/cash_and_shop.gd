extends HBoxContainer

var initial_panel_pos
var panel_open : bool = false

func _ready():
	initial_panel_pos = %ShoppingPanel.position
	_on_globals_cash_changed()



func _on_button_pressed() -> void:
	if not panel_open:
		show_shopping_panel()
		
	else:
		hide_shopping_panel()
		
	
func show_shopping_panel():
	$Button.text = "Close"
	var tween = create_tween()
	var offset_x = 128
	tween.tween_property(%ShoppingPanel, "position", initial_panel_pos + Vector2.LEFT*(%ShoppingPanel.size.x + offset_x), 0.2 )
	$SlideNoise.play()
	panel_open = true
	
func hide_shopping_panel():
	$Button.text = "Shop"
	var tween = create_tween()
	tween.tween_property(%ShoppingPanel, "position", initial_panel_pos , 0.5 )
	$SlideNoise.play()
	panel_open = false
	
func _on_globals_cash_changed():
	for button in %ButtonContainer.get_children():
		button.disable_if_insufficient_funds(Globals.cash)

func _on_factory_unlocked(_building):
	hide_shopping_panel()
