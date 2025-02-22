extends FactoryFloor

var level_won_text = "You did it! You are the best logistics supply chain loss prevention expert there is. Congratulations!!!"

func _ready() -> void:
	super()
	Globals.cash_changed.connect(_on_globals_cash_changed)

func check_win_conditions():
	# On a timer, check to see if player has X Cash, or managed to create a singularity or paradox
	pass
	
func _on_globals_cash_changed(cash):
	if cash > 5000:
		win("You made a whole lot of money! Thanks for playing.")
		
func win(text):
	Globals.cash = 0
	show_level_won_overlay(text, next_scene_path)
